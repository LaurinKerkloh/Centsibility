RSpec.describe "Alerts" do
  it "closes an error alert" do
    visit new_session_path
    fill_in "Email address", with: users.user.email_address
    fill_in "Password", with: "wrong"
    click_button "Sign in"

    within("[role='alert']", text: "Try another email address or password.") { click_button "Dismiss" }

    expect(page).to have_no_text("Try another email address or password.")
  end

  it "dismisses a success alert after its timeout", :aggregate_failures do
    success = Components::Alert::KINDS[:success].merge(timeout: 500)
    stub_const("Components::Alert::KINDS", Components::Alert::KINDS.merge(success:))
    visit new_password_path
    fill_in "Email address", with: users.user.email_address
    click_button "Email reset instructions"

    expect(page).to have_css("[role='status']", text: "Password reset instructions sent")
    expect(page).to have_no_css("[role='status']")
  end
end
