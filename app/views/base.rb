class Views::Base < Components::Base
  def page_title = "Banking"

  def around_template
    render Components::Layout.new(title: page_title) { super }
  end
end
