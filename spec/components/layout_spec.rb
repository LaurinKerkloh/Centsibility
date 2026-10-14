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

  it "renders flash messages as alerts of the mapped kind", :aggregate_failures do
    rendered = render_with_flash(notice: "Saved", alert: "Failed", info: "FYI", warning: "Careful", other: "Hidden")

    expect(rendered).to have_css("[role='status'] .text-success", text: "Saved")
    expect(rendered).to have_css("[role='alert'] .text-danger", text: "Failed")
    expect(rendered).to have_css("[role='status'] .text-info", text: "FYI")
    expect(rendered).to have_css("[role='alert'] .text-warning", text: "Careful")
    expect(rendered).to have_no_text("Hidden")
  end

  def render_with_flash(**messages)
    controller = ApplicationController.new
    controller.request = ActionDispatch::TestRequest.create
    messages.each { |key, message| controller.flash[key] = message }
    Capybara.string(described_class.new(title: "Home").render_in(controller.view_context))
  end
end
