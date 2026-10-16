class TablePreview < Lookbook::Preview
  def default
    rows = [["REWE", BigDecimal("-6.9")], ["Beispiel Software GmbH", BigDecimal("1932.91")]]

    render Components::Table.new(rows, headers: ["Counterparty", ["Amount", :right]]) do |table, (name, amount)|
      table.cell { name }
      table.cell(align: :right) { table.render Components::Amount.new(amount) }
    end
  end
end
