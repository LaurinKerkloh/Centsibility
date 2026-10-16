RSpec.describe "Accounts" do
  before { sign_in_as users.user }

  it "redirects to the login page when signed out" do
    delete session_path
    get accounts_path

    expect(response).to redirect_to(new_session_path)
  end

  describe "GET /accounts" do
    it "lists each account with its IBAN in groups and its latest balance", :aggregate_failures do
      get accounts_path

      expect(response.body).to have_title("Accounts")
      expect(response.body).to have_css("tbody tr", count: 1)
      expect(response.body).to have_css("tbody tr", exact_text: /Girokonto\s*DE45 1203 0000 1234 5678 90\s*1.616,35 € on 14.10.2026/)
      expect(response.body).to have_link("Girokonto", href: account_transactions_path(accounts.girokonto))
    end

    it "shows None for an account without balances" do
      Account.create!(name: "Tagesgeld", iban: "DE18120300001234567891")

      get accounts_path

      expect(response.body).to have_css("tbody tr", text: /Tagesgeld.*None/)
    end

    it "says when there are no accounts and links to an import", :aggregate_failures do
      [Transaction, Balance, Account].each(&:delete_all)

      get accounts_path

      expect(response.body).to have_text("No accounts yet.")
      expect(response.body).to have_link("New import", href: new_import_path)
    end
  end
end
