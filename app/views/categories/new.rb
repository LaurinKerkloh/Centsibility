class Views::Categories::New < Views::Base
  def initialize(category:)
    @category = category
  end

  def page_title = "New category"

  def view_template
    render Components::Panel.new(title: page_title) do
      render Views::Categories::Form.new(category: @category)
    end
  end
end
