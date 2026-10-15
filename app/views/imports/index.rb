class Views::Imports::Index < Views::Base
  def initialize(import:, imports:)
    @import = import
    @imports = imports
  end

  def page_title = "Imports"

  def view_template
    div(class: "w-full space-y-10") do
      h1(class: "text-2xl font-bold") { "Imports" }

      render Components::Form.new(model: @import, url: imports_path, class: "max-w-sm") do |form|
        form.file_field :file, label: "CSV file", accept: ".csv,text/csv", required: true
        form.submit "Import"
      end

      history
    end
  end

  private

  def history
    return p(class: "text-muted") { "No imports yet." } if @imports.empty?

    table(class: "w-full text-left text-sm") do
      thead(class: "border-b border-border text-muted") do
        tr do
          th(class: "py-2 pr-4 font-medium") { "Date" }
          th(class: "py-2 pr-4 font-medium") { "File" }
          th(class: "py-2 pr-4 font-medium") { "Account" }
          th(class: "py-2 pr-4 text-right font-medium") { "New" }
          th(class: "py-2 text-right font-medium") { "Skipped" }
        end
      end

      tbody(class: "divide-y divide-border") do
        @imports.each do |import|
          tr do
            td(class: "py-2 pr-4") { import.created_at.strftime("%d.%m.%Y") }
            td(class: "py-2 pr-4") { render Components::Link.new(href: import_path(import)) { import.filename } }
            td(class: "py-2 pr-4") { import.account.name }
            td(class: "py-2 pr-4 text-right tabular-nums") { import.new_count.to_s }
            td(class: "py-2 text-right tabular-nums") { import.skipped_count.to_s }
          end
        end
      end
    end
  end
end
