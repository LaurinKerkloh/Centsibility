class Views::Imports::Show < Views::Base
  def initialize(import:, transactions:)
    @import = import
    @transactions = transactions
  end

  def page_title = @import.filename

  def view_template
    div(class: "w-full space-y-10") do
      div(class: "flex items-center justify-between gap-4") do
        h1(class: "text-2xl font-bold break-all") { @import.filename }

        if @import.latest?
          render Components::Button.new(variant: :danger, href: import_path(@import), method: :delete,
            form: {data: {turbo_confirm: "Delete this import and everything it added?"}}) { "Delete import" }
        end
      end

      summary
      transaction_table
    end
  end

  private

  def summary
    dl(class: "grid grid-cols-[auto_1fr] gap-x-6 gap-y-2 text-sm") do
      item("Imported") { @import.created_at.to_fs(:de) }
      item("Account") do
        plain @import.account.name
        if @import.created_account?
          whitespace
          span(class: "rounded-md border border-primary px-1.5 text-xs text-primary") { "new" }
        end
      end
      item("New") { @transactions.size.to_s }
      item("Skipped") { @import.skipped_count.to_s }
      item("Balance") do
        if (balance = @import.balances.first)
          render Components::Amount.new(balance.amount)
          plain " on #{balance.recorded_on.to_fs(:de)}"
        else
          span(class: "text-muted") { "None" }
        end
      end
    end
  end

  def item(label, &)
    dt(class: "text-muted") { label }
    dd(&)
  end

  def transaction_table
    return p(class: "text-muted") { "No new transactions." } if @transactions.empty?

    headers = ["Booked on", "Counterparty", "Reference", ["Amount", :right]]
    render Components::Table.new(@transactions, headers:) do |table, transaction|
      table.cell(class: "whitespace-nowrap") { transaction.booked_on.to_fs(:de) }
      table.cell { transaction.counterparty&.name }
      table.cell(class: "text-muted") { transaction.reference }
      table.cell(align: :right) { render Components::Amount.new(transaction.amount) }
    end
  end
end
