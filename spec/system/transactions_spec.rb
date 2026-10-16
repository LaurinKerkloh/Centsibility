RSpec.describe "Transactions" do
  before { sign_in_as users.user }

  it "loads further pages while scrolling" do
    stub_const("Transaction::Filter::PER_PAGE", 2)
    click_link "Accounts"
    click_link "Girokonto"

    expect(page).to have_css("tbody tr", count: 5)
  end

  it "filters live, keeps the URL in sync and clears the filters", :aggregate_failures do
    visit account_transactions_path(accounts.girokonto)
    fill_in "Search", with: "ag"
    expect(page).to have_css("tbody tr", count: 2)
    expect(page.evaluate_script("document.activeElement.name")).to eq("q")

    choose "Income", allow_label_click: true
    expect(page).to have_text("No transactions match these filters.")
    expect(page).to have_current_path("#{account_transactions_path(accounts.girokonto)}?q=ag&direction=income")

    click_link "Clear filters"
    expect(page).to have_css("tbody tr", count: 5)
    expect(page).to have_field("Search", with: "")
  end

  it "shows the empty state when nothing matches" do
    visit account_transactions_path(accounts.girokonto)
    fill_in "From", with: Date.new(2027, 1, 1)

    expect(page).to have_text("No transactions match these filters.")
  end
end
