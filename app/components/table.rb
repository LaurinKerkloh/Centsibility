class Components::Table < Components::Base
  CELL = "py-2 pr-4 last:pr-0"

  def initialize(rows, headers:, body: {})
    @rows = rows
    @headers = headers
    @body = body
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

      tbody(**mix({class: "divide-y divide-border"}, @body)) { render Rows.new(@rows), &row }
    end
  end
end
