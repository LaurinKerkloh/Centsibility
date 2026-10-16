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

  it "passes attributes to the body, e.g. an id to append rows to" do
    rendered = render(described_class.new([], headers: ["Name"], body: {id: "people", class: "text-muted"}))

    expect(rendered).to have_css("tbody#people.divide-y.text-muted", visible: :all)
  end

  describe Components::Table::Rows do
    it "renders only the rows, with the same cells as the table", :aggregate_failures do
      rendered = render(described_class.new(%w[Paid])) { |rows, row| rows.cell(align: :right) { row } }

      expect(rendered).to have_no_css("table, tbody")
      expect(rendered).to have_css("body > tr > td.text-right", exact_text: "Paid")
    end
  end
end
