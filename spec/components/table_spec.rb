RSpec.describe Components::Table do
  subject(:rendered) do
    render(described_class.new(%w[Paid 2026], headers: ["Name", ["Amount", :right]])) do |table, row|
      table.cell { row }
      table.cell(align: :right) { "1" }
    end
  end

  it "renders a header cell per column, aligned like its cells", :aggregate_failures do
    expect(rendered).to have_css("thead th", count: 2)
    expect(rendered).to have_css("thead th.text-right", exact_text: "Amount")
  end

  it "renders a row per item with the cells the block adds", :aggregate_failures do
    expect(rendered).to have_css("tbody tr", count: 2)
    expect(rendered).to have_css("tbody tr:first-child td", exact_text: "Paid")
    expect(rendered).to have_css("tbody tr:last-child td.text-right", exact_text: "1")
  end
end
