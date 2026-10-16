class Views::Imports::Index < Views::Base
  def initialize(imports:)
    @imports = imports
  end

  def page_title = "Imports"

  def view_template
    div(class: "w-full space-y-10") do
      div(class: "flex items-center justify-between gap-4") do
        h1(class: "text-2xl font-bold") { "Imports" }
        render Components::Button.new(href: new_import_path) { "New import" }
      end

      history
    end
  end

  private

  def history
    return p(class: "text-muted") { "No imports yet." } if @imports.empty?

    headers = ["Date", "File", "Account", ["New", :right], ["Skipped", :right]]
    render Components::Table.new(@imports, headers:) do |table, import|
      table.cell { import.created_at.to_fs(:de) }
      table.cell { render Components::Link.new(href: import_path(import)) { import.filename } }
      table.cell { import.account.name }
      table.cell(align: :right, class: "tabular-nums") { import.new_count.to_s }
      table.cell(align: :right, class: "tabular-nums") { import.skipped_count.to_s }
    end
  end
end
