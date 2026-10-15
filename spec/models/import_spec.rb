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
end
