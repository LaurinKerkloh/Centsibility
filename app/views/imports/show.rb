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
      item("Imported") { @import.created_at.strftime("%d.%m.%Y %H:%M") }
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
          plain " on #{balance.recorded_on.strftime("%d.%m.%Y")}"
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

    table(class: "w-full text-left text-sm") do
      thead(class: "border-b border-border text-muted") do
        tr do
          th(class: "py-2 pr-4 font-medium") { "Booked on" }
          th(class: "py-2 pr-4 font-medium") { "Counterparty" }
          th(class: "py-2 pr-4 font-medium") { "Reference" }
          th(class: "py-2 text-right font-medium") { "Amount" }
        end
      end

      tbody(class: "divide-y divide-border") do
        @transactions.each do |transaction|
          tr do
            td(class: "py-2 pr-4 whitespace-nowrap") { transaction.booked_on.strftime("%d.%m.%Y") }
            td(class: "py-2 pr-4") { transaction.counterparty&.name }
            td(class: "py-2 pr-4 text-muted") { transaction.reference }
            td(class: "py-2 text-right") { render Components::Amount.new(transaction.amount) }
          end
        end
      end
    end
  end
end
