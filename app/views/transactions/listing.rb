# Shared by the page and the Turbo Stream batches, so appended rows match the first ones.
module Views::Transactions::Listing
  HEADERS = ["Booked on", "Counterparty", "Reference", ["Amount", :right]].freeze

  private

  def cells(rows, transaction)
    rows.cell(class: "whitespace-nowrap") { transaction.booked_on.to_fs(:de) }
    rows.cell { transaction.counterparty&.name }
    rows.cell(class: "text-muted") { transaction.reference }
    rows.cell(align: :right) { rows.render Components::Amount.new(transaction.amount) }
  end

  def sentinel
    return unless @filter.next_page

    url = account_transactions_path(@filter.account, **@filter.to_params, page: @filter.next_page, format: :turbo_stream)
    div(id: "transactions_more", class: "h-px", data: {controller: "infinite-scroll", infinite_scroll_url_value: url})
  end
end
