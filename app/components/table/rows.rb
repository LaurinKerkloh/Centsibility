# Rendered on its own to append rows to a table's body, e.g. from a Turbo Stream.
class Components::Table::Rows < Components::Base
  def initialize(rows)
    @rows = rows
  end

  def view_template(&row)
    @rows.each { |item| tr { row.call(self, item) } }
  end

  def cell(align: :left, **attributes, &)
    td(**mix({class: "#{Components::Table::CELL} #{"text-right" if align == :right}"}, attributes), &)
  end
end
