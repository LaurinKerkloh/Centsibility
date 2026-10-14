RSpec.describe Components::Panel do
  it "renders the title as a heading and the content below it", :aggregate_failures do
    rendered = render(described_class.new(title: "Sign in")) { "Form" }

    expect(rendered).to have_css("div h1", text: "Sign in")
    expect(rendered).to have_css("div", text: /Sign in\s*Form/)
  end
end
