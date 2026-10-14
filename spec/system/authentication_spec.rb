RSpec.describe "Authentication" do
  it "signs in and out", :aggregate_failures do
    visit root_path
    expect(page).to have_current_path(new_session_path)
    expect(page).to have_no_link("Sign up")

    sign_in_as users.user
    click_button "Sign out"

    expect(page).to have_current_path(new_session_path)
    expect(page).to have_no_button("Sign out")
  end

  it "resets the password by email", :aggregate_failures do
    visit new_session_path
    click_link "Forgot password?"
    fill_in "Email address", with: users.user.email_address
    click_button "Email reset instructions"
    expect(page).to have_text("Password reset instructions sent")
    perform_enqueued_jobs

    mail = Capybara.string(ActionMailer::Base.deliveries.last.html_part.body.to_s)
    visit URI(mail.find_link("this password reset page")[:href]).path
    fill_in "New password", with: "new-password"
    fill_in "Repeat new password", with: "new-password"
    click_button "Save"
    expect(page).to have_text("Password has been reset.")

    sign_in_as users.user, password: "new-password"
  end
end
