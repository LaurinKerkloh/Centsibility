class Views::Imports::New < Views::Base
  def initialize(import:)
    @import = import
  end

  def page_title = "New import"

  def view_template
    render Components::Panel.new(title: "New import") do
      render Components::Form.new(model: @import, url: imports_path) do |form|
        form.file_field :file, label: "CSV file", accept: ".csv,text/csv", required: true
        form.submit "Import"
      end
    end
  end
end
