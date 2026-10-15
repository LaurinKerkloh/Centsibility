RSpec.describe Importer do
  let(:sample) { Parsers::Dkb.parse(file_fixture("dkb/girokonto.csv").read) }
  let(:new_iban) { "DE08500105170007654321" }

  def entry(raw_row, counterparty_name: "Bäckerei", counterparty_iban: nil, amount: "-3.5")
    Parsers::Entry.new(booked_on: Date.new(2026, 10, 15), value_on: Date.new(2026, 10, 15), amount: BigDecimal(amount),
      counterparty_name:, counterparty_iban:, reference: "Brötchen", creditor_id: nil, mandate_reference: nil,
      customer_reference: nil, raw_row:)
  end

  def statement(*entries, iban: accounts.girokonto.iban, balance: "100", balance_on: Date.new(2026, 10, 15))
    Parsers::Statement.new(account_iban: iban, account_type: "Tagesgeld", balance: BigDecimal(balance), balance_on:, entries:)
  end

  def import(statement) = described_class.new(statement).call(import: Import.new(filename: "export.csv"))

  describe "importing the sample into the seeded account" do
    subject(:result) { import(sample) }

    it "saves every row except the seeded ones", :aggregate_failures do
      expect { result }.to change(Transaction, :count).by(sample.entries.size - 5)
      expect(result).to have_attributes(account: accounts.girokonto, skipped_count: 5)
      expect(result.transactions).to all(be_persisted)
    end

    it "saves the import", :aggregate_failures do
      expect(result.import).to have_attributes(persisted?: true, filename: "export.csv", account: accounts.girokonto,
        skipped_count: 5, created_account: false)
      expect(result.import.transactions).to match_array(result.transactions)
    end

    it "reuses the seeded counterparties without claiming them", :aggregate_failures do
      result

      expect(counterparties.employer.transactions.count).to eq(2)
      expect(counterparties.rewe.reload.import).to be_nil
    end

    it "marks the counterparties it created" do
      expect(result.import.counterparties.map(&:name)).to include("AMAZON PAYMENTS EUROPE S.C.A.", "Treatwell")
    end

    it "copies the entry fields" do
      transaction = result.transactions.find { it.customer_reference == "KKKKKKKKKKKKKKK9" }

      expect(transaction).to have_attributes(account: accounts.girokonto, booked_on: Date.new(2026, 10, 14),
        value_on: Date.new(2026, 10, 14), amount: BigDecimal("-35.99"), reference: start_with("305-1234567"),
        creditor_id: "DE11ZZZ00000123456", mandate_reference: "1aBcDeF,GhIjKlMnOpQrStUv-wxy11zA",
        counterparty: have_attributes(name: "AMAZON PAYMENTS EUROPE S.C.A.", iban: "DE53300308800001234567"))
    end

    it "adds no balance when it equals the current one", :aggregate_failures do
      expect { result }.not_to change(Balance, :count)
      expect(result.balance).to be_nil
    end

    it "writes nothing when importing the same file again", :aggregate_failures do
      import(sample)
      again = nil

      expect { again = import(sample) }.to not_change { [Import.count, Transaction.count, Counterparty.count, Balance.count] }
      expect(again).to have_attributes(import: nil, transactions: [], skipped_count: sample.entries.size, balance: nil)
    end
  end

  describe "balances" do
    let(:recorded_on) { balances.girokonto_current.recorded_on }

    it "adds a new balance when the amount for that date changed", :aggregate_failures do
      result = import(statement(balance: "42.5", balance_on: recorded_on))

      expect(result.balance).to have_attributes(persisted?: true, amount: BigDecimal("42.5"), import: result.import)
      expect(accounts.girokonto.balance_on(recorded_on)).to eq(result.balance)
      expect(balances.girokonto_current.reload.amount).to eq(BigDecimal("1616.35"))
    end

    it "adds a balance for a new date" do
      expect { import(statement) }.to change(accounts.girokonto.balances, :count).by(1)
    end

    it "saves the import for a changed balance alone" do
      expect(import(statement(balance: "42.5", balance_on: recorded_on)).import).to be_persisted
    end
  end

  it "creates the account from the statement when its IBAN is unknown", :aggregate_failures do
    result = import(statement(entry("a"), iban: new_iban))

    expect(result.account).to have_attributes(persisted?: true, name: "Tagesgeld", account_type: "Tagesgeld", iban: new_iban)
    expect(result.import).to have_attributes(account: result.account, created_account: true)
    expect(result.transactions.sole.account).to eq(result.account)
    expect(result.balance).to have_attributes(persisted?: true, account: result.account)
  end

  describe "counterparties" do
    it "finds them by IBAN, even under another name" do
      result = import(statement(entry("a", counterparty_name: "Arbeitgeber", counterparty_iban: counterparties.employer.iban)))

      expect(result.transactions.sole.counterparty).to eq(counterparties.employer)
    end

    it "finds them by name among those without IBAN" do
      result = import(statement(entry("a", counterparty_name: "REWE")))

      expect(result.transactions.sole.counterparty).to eq(counterparties.rewe)
    end

    it "does not match a name that only exists with an IBAN", :aggregate_failures do
      result = import(statement(entry("a", counterparty_name: counterparties.employer.name)))

      expect(result.transactions.sole.counterparty).to have_attributes(persisted?: true, iban: nil)
      expect(result.transactions.sole.counterparty).not_to eq(counterparties.employer)
    end

    it "shares new ones between rows of one import" do
      other_iban = "DE79120300002345678901"
      entries = [entry("a"), entry("b"), entry("c", counterparty_iban: other_iban), entry("d", counterparty_iban: other_iban)]

      expect { import(statement(*entries)) }.to change(Counterparty, :count).by(2)
    end

    it "names a new counterparty without name after its normalised IBAN" do
      result = import(statement(entry("a", counterparty_name: nil, counterparty_iban: "de79 1203 0000 2345 6789 01")))

      expect(result.transactions.sole.counterparty.name).to eq("DE79120300002345678901")
    end

    it "leaves rows without counterparty name and IBAN without counterparty" do
      result = import(statement(entry("a", counterparty_name: nil)))

      expect(result.transactions.sole.counterparty).to be_nil
    end
  end

  describe "duplicates" do
    let(:seeded_row) { transactions.direct_debit.raw_row }

    it "saves identical lines of a fresh file", :aggregate_failures do
      result = import(statement(entry("a"), entry("a")))

      expect(result).to have_attributes(skipped_count: 0)
      expect(result.transactions.size).to eq(2)
    end

    it "saves only the occurrences beyond those already in the account", :aggregate_failures do
      result = import(statement(entry(seeded_row), entry(seeded_row), entry(seeded_row)))

      expect(result).to have_attributes(skipped_count: 1)
      expect(accounts.girokonto.transactions.where(raw_row: seeded_row).count).to eq(3)
    end

    it "only compares against the same account" do
      expect(import(statement(entry(seeded_row), iban: new_iban)).skipped_count).to eq(0)
    end
  end

  it "saves nothing when a record is invalid" do
    invalid = statement(entry("a"), entry("b", counterparty_iban: "DE00123"), iban: new_iban)

    expect { import(invalid) }.to raise_error(ActiveRecord::RecordInvalid)
      .and not_change { [Import.count, Account.count, Transaction.count, Counterparty.count, Balance.count] }
  end
end
