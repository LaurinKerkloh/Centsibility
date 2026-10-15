RSpec.describe Importer do
  let(:sample) { Parsers::Dkb.parse(file_fixture("dkb/girokonto.csv").read) }

  def entry(raw_row, counterparty_name: "Bäckerei", counterparty_iban: nil, amount: "-3.5")
    Parsers::Entry.new(booked_on: Date.new(2026, 10, 15), value_on: Date.new(2026, 10, 15), amount: BigDecimal(amount),
      counterparty_name:, counterparty_iban:, reference: "Brötchen", creditor_id: nil, mandate_reference: nil,
      customer_reference: nil, raw_row:)
  end

  def statement(*entries, iban: accounts.girokonto.iban, balance: "100", balance_on: Date.new(2026, 10, 15))
    Parsers::Statement.new(account_iban: iban, account_type: "Tagesgeld", balance: BigDecimal(balance), balance_on:, entries:)
  end

  describe "importing the sample into the seeded account" do
    subject(:result) { described_class.new(sample).call }

    it "saves every row except the seeded ones", :aggregate_failures do
      expect { result }.to change(Transaction, :count).by(sample.entries.size - 5)
      expect(result).to have_attributes(account: accounts.girokonto, skipped_count: 5)
      expect(result.transactions).to all(be_persisted)
    end

    it "reuses the seeded counterparties", :aggregate_failures do
      result

      expect(counterparties.employer.transactions.count).to eq(2)
      expect(counterparties.rewe.transactions.count).to be > 1
    end

    it "copies the entry fields" do
      transaction = result.transactions.find { it.customer_reference == "KKKKKKKKKKKKKKK9" }

      expect(transaction).to have_attributes(account: accounts.girokonto, booked_on: Date.new(2026, 10, 14),
        value_on: Date.new(2026, 10, 14), amount: BigDecimal("-35.99"), reference: start_with("305-1234567"),
        creditor_id: "DE11ZZZ00000123456", mandate_reference: "1aBcDeF,GhIjKlMnOpQrStUv-wxy11zA",
        counterparty: have_attributes(name: "AMAZON PAYMENTS EUROPE S.C.A.", iban: "DE53300308800001234567"))
    end

    it "overwrites the balance for the same date", :aggregate_failures do
      expect { result }.not_to change(Balance, :count)
      expect(result.balance).to eq(balances.girokonto_current)
    end

    it "saves nothing when importing the same file again" do
      described_class.new(sample).call

      expect { described_class.new(sample).call }.not_to change(Transaction, :count)
    end
  end

  it "creates the account from the statement when its IBAN is unknown", :aggregate_failures do
    result = described_class.new(statement(entry("a"), iban: "DE08500105170007654321")).call

    expect(result.account).to have_attributes(persisted?: true, name: "Tagesgeld", account_type: "Tagesgeld",
      iban: "DE08500105170007654321")
    expect(result.transactions.sole.account).to eq(result.account)
  end

  it "updates the balance amount for an existing date", :aggregate_failures do
    result = described_class.new(statement(balance: "42.5", balance_on: balances.girokonto_current.recorded_on)).call

    expect(balances.girokonto_current.reload.amount).to eq(BigDecimal("42.5"))
    expect(result.balance).to eq(balances.girokonto_current)
  end

  it "adds a balance for a new date" do
    expect { described_class.new(statement).call }.to change(accounts.girokonto.balances, :count).by(1)
  end

  describe "counterparties" do
    it "finds them by IBAN, even under another name" do
      result = described_class.new(statement(entry("a", counterparty_name: "Arbeitgeber", counterparty_iban: counterparties.employer.iban))).call

      expect(result.transactions.sole.counterparty).to eq(counterparties.employer)
    end

    it "finds them by name among those without IBAN" do
      result = described_class.new(statement(entry("a", counterparty_name: "REWE"))).call

      expect(result.transactions.sole.counterparty).to eq(counterparties.rewe)
    end

    it "does not match a name that only exists with an IBAN", :aggregate_failures do
      result = described_class.new(statement(entry("a", counterparty_name: counterparties.employer.name))).call

      expect(result.transactions.sole.counterparty).to have_attributes(persisted?: true, iban: nil)
      expect(result.transactions.sole.counterparty).not_to eq(counterparties.employer)
    end

    it "shares new ones between rows of one import" do
      new_iban = "DE79120300002345678901"
      entries = [entry("a"), entry("b"), entry("c", counterparty_iban: new_iban), entry("d", counterparty_iban: new_iban)]

      expect { described_class.new(statement(*entries)).call }.to change(Counterparty, :count).by(2)
    end

    it "leaves rows without counterparty name and IBAN without counterparty" do
      result = described_class.new(statement(entry("a", counterparty_name: nil))).call

      expect(result.transactions.sole.counterparty).to be_nil
    end
  end

  describe "duplicates" do
    let(:seeded_row) { transactions.direct_debit.raw_row }

    it "saves identical lines of a fresh file", :aggregate_failures do
      result = described_class.new(statement(entry("a"), entry("a"))).call

      expect(result).to have_attributes(skipped_count: 0)
      expect(result.transactions.size).to eq(2)
    end

    it "saves only the occurrences beyond those already in the account", :aggregate_failures do
      result = described_class.new(statement(entry(seeded_row), entry(seeded_row), entry(seeded_row))).call

      expect(result).to have_attributes(skipped_count: 1)
      expect(accounts.girokonto.transactions.where(raw_row: seeded_row).count).to eq(3)
    end

    it "only compares against the same account" do
      result = described_class.new(statement(entry(seeded_row), iban: "DE08500105170007654321")).call

      expect(result.skipped_count).to eq(0)
    end
  end

  it "saves nothing when a record is invalid" do
    importer = described_class.new(statement(entry("a"), entry("b", counterparty_iban: "DE00123"), iban: "DE08500105170007654321"))

    expect { importer.call }.to raise_error(ActiveRecord::RecordInvalid)
      .and not_change { [Account.count, Transaction.count, Counterparty.count, Balance.count] }
  end

  describe "dry run" do
    it "writes nothing" do
      expect { described_class.new(sample).call(dry_run: true) }
        .to not_change(Transaction, :count)
        .and not_change(Counterparty, :count)
        .and not_change { balances.girokonto_current.reload.updated_at }
    end

    it "does not create the account" do
      expect { described_class.new(statement(entry("a"), iban: "DE08500105170007654321")).call(dry_run: true) }
        .not_to change(Account, :count)
    end

    it "returns the same result as a real import", :aggregate_failures do
      dry = described_class.new(sample).call(dry_run: true)
      real = described_class.new(sample).call

      expect(dry.transactions.map(&:raw_row)).to eq(real.transactions.map(&:raw_row))
      expect(dry).to have_attributes(account: real.account, skipped_count: real.skipped_count)
      expect(dry.balance).to have_attributes(recorded_on: real.balance.recorded_on, amount: real.balance.amount)
    end
  end
end
