class Views::Categories::Edit < Views::Base
  def initialize(category:)
    @category = category
  end

  # The stored name, so a rejected rename doesn't show up in the title.
  def page_title = "Edit #{@category.name_in_database}"

  def view_template
    render Components::Panel.new(title: page_title) do
      render Views::Categories::Form.new(category: @category)
    end
  end
end
