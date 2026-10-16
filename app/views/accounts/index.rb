class Views::Accounts::Index < Views::Base
  def initialize(accounts:)
    @accounts = accounts
  end

  def page_title = "Accounts"

  def view_template
    div(class: "w-full space-y-10") do
      h1(class: "text-2xl font-bold") { "Accounts" }

      if @accounts.empty?
        p(class: "text-muted") do
          plain "No accounts yet. "
          render Components::Link.new(href: new_import_path) { "New import" }
        end
      else
        list
      end
    end
  end

  private

  def list
    render Components::Table.new(@accounts, headers: ["Name", "IBAN", ["Balance", :right]]) do |table, account|
      table.cell { render Components::Link.new(href: account_transactions_path(account)) { account.name } }
      table.cell(class: "whitespace-nowrap tabular-nums") { account.iban.scan(/.{1,4}/).join(" ") }
      table.cell(align: :right) { balance(account.latest_balance) }
    end
  end

  def balance(balance)
    return span(class: "text-muted") { "None" } unless balance

    render Components::Amount.new(balance.amount)
    plain " on #{balance.recorded_on.to_fs(:de)}"
  end
end
