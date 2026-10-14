RSpec.describe "Home" do
  it "shows the home page", :aggregate_failures do
    visit root_path

    expect(page).to have_title("Banking")
    expect(page).to have_css("h1", text: "Home")
  end
end
