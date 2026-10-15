RSpec.describe Components::Amount do
  it "formats a negative amount in German notation" do
    expect(render(described_class.new(BigDecimal("-6.9"))).text).to eq("-6,90 €")
  end

  it "groups thousands with dots" do
    expect(render(described_class.new(BigDecimal("1616.35"))).text).to eq("1.616,35 €")
  end
end
