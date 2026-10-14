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

    expect(rendered).to have_css("header form[action='/session'] button", text: "Sign out")
  end
end
