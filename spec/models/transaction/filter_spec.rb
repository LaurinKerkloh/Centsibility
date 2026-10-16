RSpec.describe Transaction::Filter do
  let(:girokonto) { accounts.girokonto }

  def filter(**params) = described_class.new(account: girokonto, **params)

  def create_transaction(booked_on: "2026-10-15", amount: "-1", reference: nil, counterparty: nil, account: girokonto)
    account.transactions.create!(booked_on:, value_on: booked_on, amount:, reference:, counterparty:,
      raw_row: SecureRandom.hex)
  end

  describe "#transactions" do
    it "returns the account's transactions, newest first and by id within a day" do
      first = create_transaction(booked_on: "2026-10-14")
      second = create_transaction(booked_on: "2026-10-14")

      expect(filter.transactions.first(3)).to eq([second, first, transactions.direct_debit])
    end

    it "leaves out other accounts' transactions" do
      other = Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891")
      create_transaction(account: other)

      expect(filter.transactions).to match_array(girokonto.transactions)
    end

    it "matches the search case-insensitively in the counterparty name or the reference", :aggregate_failures do
      expect(filter(q: "rewe").transactions).to eq([transactions.card_payment])
      expect(filter(q: "gehalt").transactions).to eq([transactions.salary])
    end

    it "treats LIKE wildcards in the search literally" do
      create_transaction(reference: "100% Bio")

      expect(filter(q: "0%").transactions.map(&:reference)).to eq(["100% Bio"])
    end

    it "keeps transactions without a counterparty that match by reference" do
      create_transaction(reference: "Bargeld")

      expect(filter(q: "bargeld").transactions.map(&:reference)).to eq(["Bargeld"])
    end

    it "limits by booking date, inclusive on both ends", :aggregate_failures do
      expect(filter(from: "2026-10-02", to: "2026-10-05").transactions)
        .to eq([transactions.card_payment, transactions.account_fee])
      expect(filter(from: "2026-10-05").transactions).to eq([transactions.direct_debit, transactions.card_payment])
      expect(filter(to: "2026-08-29").transactions).to eq([transactions.savings_transfer])
    end

    it "ignores unparseable dates" do
      expect(filter(from: "soon").transactions.size).to eq(5)
    end

    it "filters by direction, leaving zero amounts to all", :aggregate_failures do
      create_transaction(amount: "0")

      expect(filter(direction: "income").transactions).to eq([transactions.salary])
      expect(filter(direction: "spending").transactions.size).to eq(4)
      expect(filter(direction: "anything").transactions.size).to eq(6)
    end

    it "combines filters" do
      expect(filter(q: "e", direction: "income", from: "2026-09-01").transactions).to eq([transactions.salary])
    end
  end

  describe "paging" do
    before { stub_const("#{described_class}::PER_PAGE", 2) }

    it "returns one page at a time with the number of the next", :aggregate_failures do
      expect(filter.transactions).to eq([transactions.direct_debit, transactions.card_payment])
      expect(filter.next_page).to eq(2)
      expect(filter(page: "3").transactions).to eq([transactions.savings_transfer])
      expect(filter(page: "3").next_page).to be_nil
    end

    it "treats pages below 1 as the first" do
      expect(filter(page: "0").transactions.first).to eq(transactions.direct_debit)
    end

    it "tells whether it is on the first page", :aggregate_failures do
      expect(filter.first_page?).to be(true)
      expect(filter(page: "0").first_page?).to be(true)
      expect(filter(page: "2").first_page?).to be(false)
    end
  end

  describe "#any?" do
    it "is true when a filter is set", :aggregate_failures do
      expect(filter.any?).to be(false)
      expect(filter(page: "2", direction: "all").any?).to be(false)
      expect(filter(q: "rewe").any?).to be(true)
      expect(filter(direction: "income").any?).to be(true)
      expect(filter(to: "2026-10-01").any?).to be(true)
    end
  end

  describe "#to_params" do
    it "returns only the set filters" do
      expect(filter(q: "rewe", from: "2026-10-01", to: "", direction: "spending", page: "2").to_params)
        .to eq(q: "rewe", from: Date.new(2026, 10, 1), direction: "spending")
    end
  end
end
