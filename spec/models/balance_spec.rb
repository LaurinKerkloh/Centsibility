RSpec.describe Balance do
  subject(:balance) { described_class.new(account: accounts.girokonto, recorded_on: Date.new(2026, 10, 15), amount: "1616.35") }

  it "is valid with an account, a date and an amount" do
    expect(balance).to be_valid
  end

  %i[account recorded_on amount].each do |attribute|
    it "requires #{attribute}" do
      balance.public_send(:"#{attribute}=", nil)

      expect(balance).not_to be_valid
    end
  end

  it "allows one balance per account and date" do
    balance.recorded_on = balances.girokonto_current.recorded_on

    expect(balance).not_to be_valid
  end

  it "enforces one balance per account and date in the database" do
    balance.recorded_on = balances.girokonto_current.recorded_on

    expect { balance.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end
end
