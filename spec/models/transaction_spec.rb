RSpec.describe Transaction do
  subject(:transaction) do
    described_class.new(account: accounts.girokonto, booked_on: Date.new(2026, 10, 12), value_on: Date.new(2026, 10, 12),
      amount: "-87.87", raw_row: '"12.10.26";"12.10.26";"Gebucht";"ISSUER";"BAUHAUS"')
  end

  it "is valid without a counterparty" do
    expect(transaction).to be_valid
  end

  it "belongs to a counterparty" do
    expect(transactions.salary.counterparty).to eq(counterparties.employer)
  end

  it "requires an account" do
    transaction.account = nil

    expect(transaction).not_to be_valid
  end

  %i[booked_on value_on amount raw_row].each do |attribute|
    it "requires #{attribute}" do
      transaction.public_send(:"#{attribute}=", nil)

      expect(transaction).not_to be_valid
    end
  end

  it "rounds the amount to cents" do
    transaction.amount = "-87.874"

    expect(transaction.amount).to eq(BigDecimal("-87.87"))
  end
end
