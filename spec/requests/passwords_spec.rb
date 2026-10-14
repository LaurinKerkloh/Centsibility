RSpec.describe "Passwords" do
  let(:user) { users.user }
  let(:token) { user.password_reset_token }

  it "rejects a blank password", :aggregate_failures do
    put password_path(token), params: {password: "", password_confirmation: ""}

    expect(response).to redirect_to(edit_password_path(token))
    expect(user.reload.authenticate("password")).to be_truthy
  end

  it "rejects a missing confirmation" do
    put password_path(token), params: {password: "new-password"}

    expect(user.reload.authenticate("password")).to be_truthy
  end

  it "shows why the new password was rejected" do
    put password_path(token), params: {password: "new-password", password_confirmation: "other"}
    follow_redirect!

    expect(response.body).to have_css("[role='alert']", text: "Password confirmation doesn't match Password")
  end
end
