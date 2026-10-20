RSpec.describe "Categories" do
  before { sign_in_as users.user }

  it "creates a subcategory, hiding the colour while a parent is selected", :aggregate_failures do
    click_link "Categories"
    click_link "New category"
    expect(page).to have_select("Colour")

    select "Health", from: "Parent"
    expect(page).to have_no_select("Colour")

    select "", from: "Parent"
    expect(page).to have_select("Colour")

    fill_in "Name", with: "Vet"
    select "Health", from: "Parent"
    click_button "Save"

    expect(page).to have_text("Created Vet.")
    expect(page).to have_css("td span", exact_text: "Health › Vet")
  end

  it "hides the colour when editing a subcategory" do
    visit edit_category_path(categories.rent)

    expect(page).to have_no_select("Colour")
  end

  it "deletes a category after confirming" do
    visit categories_path

    accept_confirm("Delete Health and its subcategories?") do
      within("tr", text: /\AHealth\b/, match: :first) { click_button "Delete" }
    end

    expect(page).to have_text("Deleted Health.")
  end
end
