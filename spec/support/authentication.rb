module RequestAuthenticationHelpers
  def sign_in_as(user, password: "password")
    post session_path, params: {email_address: user.email_address, password:}
  end
end

module SystemAuthenticationHelpers
  def sign_in_as(user, password: "password")
    visit new_session_path
    fill_in "Email address", with: user.email_address
    fill_in "Password", with: password
    click_button "Sign in"
    expect(page).to have_button("Sign out")
  end
end

RSpec.configure do |config|
  config.include RequestAuthenticationHelpers, type: :request
  config.include SystemAuthenticationHelpers, type: :system
end
