RSpec.describe Import do
  subject(:import) { described_class.new(account: accounts.girokonto, filename: "girokonto.csv", skipped_count: 0) }

  it "is valid with an account, a filename and a skipped count" do
    expect(import).to be_valid
  end

  %i[account filename skipped_count].each do |attribute|
    it "requires #{attribute}" do
      import.public_send(:"#{attribute}=", nil)

      expect(import).not_to be_valid
    end
  end

  it "keeps its account from being deleted" do
    import.save!
    accounts.girokonto.transactions.destroy_all
    accounts.girokonto.balances.destroy_all

    expect(accounts.girokonto.destroy).to be(false)
  end

  context "with imported statements" do
    let(:new_iban) { "DE08500105170007654321" }

    def import(statement) = Importer.new(statement).call(import: described_class.new(filename: "export.csv")).import

    describe "#latest?" do
      let!(:first) { import(statement(entry("a", counterparty_name: "REWE"))) }
      let!(:second) { import(statement(entry("b", counterparty_name: "REWE"))) }

      it "is true only for the newest import of its account", :aggregate_failures do
        expect(first).not_to be_latest
        expect(second).to be_latest
      end

      it "goes by insertion order, not by timestamps" do
        second.update_columns(created_at: first.created_at - 1.day)

        expect(second).to be_latest
      end

      it "ignores imports of other accounts" do
        expect(import(statement(entry("c", counterparty_name: "REWE"), iban: new_iban))).to be_latest
      end
    end

    describe "#revert!" do
      it "deletes the import with its transactions and balance" do
        reverted = import(statement(entry("a", counterparty_name: "REWE"), entry("b", counterparty_name: "REWE")))

        expect { reverted.revert! }
          .to change(Transaction, :count).by(-2)
          .and change(Balance, :count).by(-1)
          .and change(described_class, :count).by(-1)
      end

      it "makes the previous balance of that day current again" do
        import(statement(balance: "50", balance_on: Date.new(2026, 10, 14))).revert!

        expect(accounts.girokonto.balance_on(Date.new(2026, 10, 14))).to eq(balances.girokonto_current)
      end

      it "deletes the counterparties it created that have no transactions left", :aggregate_failures do
        reverted = import(statement(entry("a", counterparty_name: "Bäckerei"), entry("b", counterparty_name: "REWE")))

        expect { reverted.revert! }.to change(Counterparty, :count).by(-1)
        expect(Counterparty.exists?(name: "Bäckerei")).to be(false)
        expect(Counterparty.exists?(counterparties.rewe.id)).to be(true)
      end

      it "keeps the counterparties it created that later imports still use" do
        reverted = import(statement(entry("a", counterparty_name: "Bäckerei")))
        import(statement(entry("b", counterparty_name: "Bäckerei")))

        expect { reverted.revert! }.to change { Counterparty.find_by(name: "Bäckerei")&.import_id }.from(reverted.id).to(nil)
      end

      it "deletes the account it created" do
        reverted = import(statement(entry("a", counterparty_name: "REWE"), iban: new_iban))

        expect { reverted.revert! }.to change(Account, :count).by(-1)
      end

      it "keeps an account it did not create" do
        expect { import(statement).revert! }.not_to change(Account, :count)
      end
    end
  end
end
