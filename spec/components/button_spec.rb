RSpec.describe Components::Button do
  it "renders a primary button of type button by default" do
    rendered = render(described_class.new) { "Save" }

    expect(rendered).to have_css("button[type='button'].bg-primary", text: "Save")
  end

  it "passes the type and extra attributes to the button" do
    rendered = render(described_class.new(type: :submit, name: "commit")) { "Save" }

    expect(rendered).to have_css("button[type='submit'][name='commit']", text: "Save")
  end

  it "renders the secondary and danger variants", :aggregate_failures do
    expect(render(described_class.new(variant: :secondary)) { "Cancel" }).to have_css("button.border-border", text: "Cancel")
    expect(render(described_class.new(variant: :danger)) { "Delete" }).to have_css("button.bg-danger", text: "Delete")
  end

  it "renders a link that looks like a button when given an href" do
    rendered = render(described_class.new(variant: :secondary, href: "/rules/new")) { "New rule" }

    expect(rendered).to have_css("a[href='/rules/new'].border-border", text: "New rule")
  end

  it "renders a link for an explicit GET method" do
    rendered = render(described_class.new(href: "/rules", method: :get)) { "Rules" }

    expect(rendered).to have_css("a[href='/rules']", text: "Rules")
  end

  it "renders a button_to form for a non-GET method", :aggregate_failures do
    rendered = render(described_class.new(href: "/session", method: :delete)) { "Sign out" }

    expect(rendered).to have_css("form[action='/session'] input[name='_method'][value='delete']", visible: :hidden)
    expect(rendered).to have_css("form[action='/session'] button[type='submit'].bg-primary", text: "Sign out")
  end
end
