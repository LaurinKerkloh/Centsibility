RSpec.describe "Sessions" do
  it "keeps the health check public" do
    get rails_health_check_path

    expect(response).to have_http_status(:ok)
  end

  it "renders the login page without a sign-out button", :aggregate_failures do
    get new_session_path

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.at_css("title").text).to eq("Sign in")
    expect(response.parsed_body.at_css("form[action='#{session_path}'] input[name='email_address']")).to be_present
    expect(response.parsed_body.at_css("button", text: "Sign out")).to be_nil
  end

  it "signs in and returns to the requested page", :aggregate_failures do
    get root_path
    sign_in_as users.user

    expect(response).to redirect_to(root_url)
    follow_redirect!
    expect(response.parsed_body.at_css("form[action='#{session_path}'] button").text).to eq("Sign out")
  end

  it "rejects invalid credentials with an alert", :aggregate_failures do
    sign_in_as users.user, password: "wrong"

    expect(response).to redirect_to(new_session_path)
    follow_redirect!
    expect(response.parsed_body.at_css("[role='alert']").text).to include("Try another email address or password.")
  end

  it "signs out", :aggregate_failures do
    sign_in_as users.user
    delete session_path

    expect(response).to redirect_to(new_session_path)
    get root_path
    expect(response).to redirect_to(new_session_path)
  end
end
