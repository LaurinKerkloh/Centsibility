RSpec.describe "Home" do
  it "renders the home page inside the layout", :aggregate_failures do
    sign_in_as users.user
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to have_title("Banking", exact: true)
    expect(response.body).to have_css("main h1", exact_text: "Home")
  end

  it "redirects to the login page when signed out" do
    get root_path

    expect(response).to redirect_to(new_session_path)
  end
end
