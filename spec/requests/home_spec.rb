RSpec.describe "Home" do
  it "renders the home page inside the layout", :aggregate_failures do
    sign_in_as users.user
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.parsed_body.at_css("title").text).to eq("Banking")
    expect(response.parsed_body.at_css("main h1").text).to eq("Home")
  end

  it "redirects to the login page when signed out" do
    get root_path

    expect(response).to redirect_to(new_session_path)
  end
end
