# Shared by every transaction table, so appended and imported rows look like the listed ones.
module Views::Transactions::Cells
  HEADERS = ["Booked on", "Counterparty", "Reference", "Category", ["Amount", :right]].freeze

  private

  def cells(rows, transaction)
    rows.cell(class: "whitespace-nowrap") { transaction.booked_on.to_fs(:de) }
    rows.cell { transaction.counterparty&.name }
    rows.cell(class: "text-muted") { transaction.reference }
    if transaction.category
      rows.cell { rows.render Components::CategoryBadge.new(transaction.category) }
    else
      rows.cell(class: "text-muted") { "—" }
    end
    rows.cell(align: :right) { rows.render Components::Amount.new(transaction.amount) }
  end
end
