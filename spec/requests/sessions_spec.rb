RSpec.describe "Sessions" do
  it "keeps the health check public" do
    get rails_health_check_path

    expect(response).to have_http_status(:ok)
  end

  it "renders the login page without a sign-out button", :aggregate_failures do
    get new_session_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to have_title("Sign in")
    expect(response.body).to have_css("form[action='#{session_path}'] input[name='email_address']")
    expect(response.body).to have_no_button("Sign out")
  end

  it "shows the sign-out button on public pages when signed in" do
    sign_in_as users.user
    get new_session_path

    expect(response.body).to have_button("Sign out")
  end

  it "signs in and returns to the requested page", :aggregate_failures do
    get root_path(from: "bookmark")
    sign_in_as users.user

    expect(response).to redirect_to(root_url(from: "bookmark"))
    follow_redirect!
    expect(response.body).to have_css("form[action='#{session_path}'] button", text: "Sign out")
  end

  it "does not return to a non-GET request after signing in" do
    delete session_path
    sign_in_as users.user

    expect(response).to redirect_to(root_url)
  end

  it "rejects invalid credentials with an alert", :aggregate_failures do
    sign_in_as users.user, password: "wrong"

    expect(response).to redirect_to(new_session_path)
    follow_redirect!
    expect(response.body).to have_css("[role='alert']", text: "Try another email address or password.")
  end

  it "signs out", :aggregate_failures do
    sign_in_as users.user
    delete session_path

    expect(response).to redirect_to(new_session_path)
    get root_path
    expect(response).to redirect_to(new_session_path)
  end
end
