RSpec.describe "Home" do
  it "shows the home page", :aggregate_failures do
    sign_in_as users.user

    expect(page).to have_title("Tallune")
    expect(page).to have_css("h1", text: "Home")
  end
end
