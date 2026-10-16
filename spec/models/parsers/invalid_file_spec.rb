RSpec.describe Parsers::InvalidFile do
  it "translates its message from the parser errors" do
    expect(described_class.new(:unknown_status, line: 6, status: "Storniert").message).to eq('Line 6: unknown status "Storniert".')
  end
end
