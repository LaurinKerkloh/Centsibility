RSpec.describe Components::Layout do
  it "renders the title and the content inside main", :aggregate_failures do
    rendered = render(described_class.new(title: "Accounts")) { "Hello" }

    expect(rendered).to have_title("Accounts")
    expect(rendered).to have_css("main", text: "Hello")
  end

  it "hides the sign-out button when signed out" do
    rendered = render(described_class.new(title: "Sign in"))

    expect(rendered).to have_no_button("Sign out")
  end

  it "shows a sign-out button when signed in" do
    rendered = Current.set(session: users.user.sessions.create!) do
      render(described_class.new(title: "Home"))
    end

    expect(rendered).to have_css("header form[action='/session'] button.border-border", text: "Sign out")
  end

  it "links to the accounts, imports and categories in the header when signed in", :aggregate_failures do
    signed_in = Current.set(session: users.user.sessions.create!) { render(described_class.new(title: "Home")) }

    expect(signed_in).to have_css("header nav a[href='/accounts']", text: "Accounts")
    expect(signed_in).to have_css("header nav a[href='/imports']", text: "Imports")
    expect(signed_in).to have_css("header nav a[href='/categories']", text: "Categories")
  end

  it "hides the links when signed out", :aggregate_failures do
    signed_out = render(described_class.new(title: "Sign in"))

    expect(signed_out).to have_no_link("Accounts")
    expect(signed_out).to have_no_link("Imports")
  end

  it "renders notice and alert flashes as success and error alerts", :aggregate_failures do
    rendered = render(described_class.new(title: "Home"), flash: {notice: "Saved", alert: "Failed"})

    expect(rendered).to have_css("[role='status'] .text-success", text: "Saved")
    expect(rendered).to have_css("[role='alert'] .text-danger", text: "Failed")
  end

  it "renders info and warning flashes as alerts of the same kind", :aggregate_failures do
    rendered = render(described_class.new(title: "Home"), flash: {info: "FYI", warning: "Careful"})

    expect(rendered).to have_css("[role='status'] .text-info", text: "FYI")
    expect(rendered).to have_css("[role='alert'] .text-warning", text: "Careful")
  end

  it "ignores other flash keys" do
    rendered = render(described_class.new(title: "Home"), flash: {other: "Hidden"})

    expect(rendered).to have_no_text("Hidden")
  end
end
