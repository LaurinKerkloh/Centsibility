RSpec.describe Counterparty do
  it "requires a name" do
    expect(described_class.new(name: "")).not_to be_valid
  end

  it "requires a unique IBAN" do
    counterparty = described_class.new(name: "Other name", iban: counterparties.employer.iban)

    expect(counterparty).not_to be_valid
  end

  it "requires a unique name among counterparties without an IBAN" do
    expect(described_class.new(name: counterparties.rewe.name)).not_to be_valid
  end

  it "allows the name of a counterparty without an IBAN when it has one" do
    expect(described_class.new(name: counterparties.rewe.name, iban: "DE79120300002345678901")).to be_valid
  end

  it "allows the name of a counterparty with an IBAN when it has none" do
    expect(described_class.new(name: counterparties.employer.name)).to be_valid
  end

  it "enforces unique IBANs in the database" do
    counterparty = described_class.new(name: "Other name", iban: counterparties.employer.iban)

    expect { counterparty.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "enforces unique names without an IBAN in the database" do
    counterparty = described_class.new(name: counterparties.rewe.name)

    expect { counterparty.save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it "cannot be deleted while it has transactions" do
    expect(counterparties.rewe.destroy).to be(false)
  end

  it "can be deleted without transactions" do
    counterparty = described_class.create!(name: "Peter Beispiel")

    expect(counterparty.destroy).to be_destroyed
  end
end
