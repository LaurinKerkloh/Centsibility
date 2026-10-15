class Components::Table < Components::Base
  CELL = "py-2 pr-4 last:pr-0"

  # headers: labels, or [label, :right] for right-aligned columns.
  def initialize(rows, headers:)
    @rows = rows
    @headers = headers
  end

  def view_template(&row)
    table(class: "w-full text-left text-sm") do
      thead(class: "border-b border-border text-muted") do
        tr do
          @headers.each do |label, align|
            th(class: "#{CELL} font-medium #{"text-right" if align == :right}") { label }
          end
        end
      end

      tbody(class: "divide-y divide-border") do
        @rows.each { |item| tr { row.call(self, item) } }
      end
    end
  end

  def cell(align: :left, **attributes, &)
    td(**mix({class: "#{CELL} #{"text-right" if align == :right}"}, attributes), &)
  end
end
