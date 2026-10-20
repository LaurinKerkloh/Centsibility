class Views::Base < Components::Base
  def page_title = "Centsibility"

  def around_template
    render Components::Layout.new(title: page_title) { super }
  end
end
