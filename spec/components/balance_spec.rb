RSpec.describe Components::Balance do
  it "renders the amount with its date" do
    rendered = render(described_class.new(Balance.new(amount: "1616.35", recorded_on: Date.new(2026, 10, 14))))

    expect(rendered).to have_text("1.616,35 € on 14.10.2026", exact: true)
  end

  it "renders a muted None without a balance" do
    expect(render(described_class.new(nil))).to have_css("span.text-muted", exact_text: "None")
  end
end
