RSpec.describe Transaction::Filter do
  let(:girokonto) { accounts.girokonto }

  def filtered(**criteria)
    girokonto.transactions.filtered(described_class.new(**criteria)).to_a
  end

  def create_transaction(booked_on: "2026-10-15", amount: "-1", reference: nil, counterparty: nil, account: girokonto)
    account.transactions.create!(booked_on:, value_on: booked_on, amount:, reference:, counterparty:,
      raw_row: SecureRandom.hex)
  end

  describe "Transaction.filtered" do
    it "orders newest first and by id within a day" do
      first = create_transaction(booked_on: "2026-10-14")
      second = create_transaction(booked_on: "2026-10-14")

      expect(filtered.first(3)).to eq([second, first, transactions.direct_debit])
    end

    it "keeps the relation's scope" do
      other = Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891")
      create_transaction(account: other)

      expect(filtered).to match_array(girokonto.transactions)
    end

    it "matches the search case-insensitively in the counterparty name or the reference", :aggregate_failures do
      expect(filtered(q: "rewe")).to eq([transactions.card_payment])
      expect(filtered(q: "gehalt")).to eq([transactions.salary])
    end

    it "treats LIKE wildcards in the search literally" do
      create_transaction(reference: "100% Bio")

      expect(filtered(q: "0%").map(&:reference)).to eq(["100% Bio"])
    end

    it "keeps transactions without a counterparty that match by reference" do
      create_transaction(reference: "Bargeld")

      expect(filtered(q: "bargeld").map(&:reference)).to eq(["Bargeld"])
    end

    it "limits by booking date, inclusive on both ends", :aggregate_failures do
      expect(filtered(from: "2026-10-02", to: "2026-10-05")).to eq([transactions.card_payment, transactions.account_fee])
      expect(filtered(from: "2026-10-05")).to eq([transactions.direct_debit, transactions.card_payment])
      expect(filtered(to: "2026-08-29")).to eq([transactions.savings_transfer])
    end

    it "ignores unparseable dates" do
      expect(filtered(from: "soon").size).to eq(5)
    end

    it "filters by direction, leaving zero amounts to all", :aggregate_failures do
      create_transaction(amount: "0")

      expect(filtered(direction: "income")).to eq([transactions.salary])
      expect(filtered(direction: "spending").size).to eq(4)
      expect(filtered(direction: "anything").size).to eq(6)
    end

    it "filters by category, including a main category's subcategories", :aggregate_failures do
      expect(filtered(category: categories.groceries.id.to_s)).to eq([transactions.card_payment])
      expect(filtered(category: categories.income.id.to_s)).to eq([transactions.salary])
      expect(filtered(category: categories.savings.id.to_s)).to eq([transactions.savings_transfer])
    end

    it "filters for uncategorised transactions" do
      uncategorised = create_transaction

      expect(filtered(category: "none")).to eq([uncategorised])
    end

    it "ignores an unknown category" do
      expect(filtered(category: "0").size).to eq(5)
    end

    it "combines filters" do
      expect(filtered(q: "e", direction: "income", from: "2026-09-01")).to eq([transactions.salary])
    end
  end

  describe "#any?" do
    it "is true when a filter is set", :aggregate_failures do
      expect(described_class.new.any?).to be(false)
      expect(described_class.new(direction: "all").any?).to be(false)
      expect(described_class.new(q: "rewe").any?).to be(true)
      expect(described_class.new(direction: "income").any?).to be(true)
      expect(described_class.new(to: "2026-10-01").any?).to be(true)
    end

    it "counts only a known category or none", :aggregate_failures do
      expect(described_class.new(category: "none").any?).to be(true)
      expect(described_class.new(category: "0").any?).to be(false)
    end
  end

  describe "#to_params" do
    it "returns only the set filters" do
      expect(described_class.new(q: "rewe", from: "2026-10-01", to: "", direction: "spending").to_params)
        .to eq(q: "rewe", from: Date.new(2026, 10, 1), direction: "spending")
    end

    it "includes a known category or none", :aggregate_failures do
      expect(described_class.new(category: categories.rent.id.to_s).to_params).to eq(category: categories.rent.id.to_s)
      expect(described_class.new(category: "none").to_params).to eq(category: "none")
    end
  end
end
