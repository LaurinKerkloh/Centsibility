class Components::Link < Components::Base
  def initialize(href:, **attributes)
    @href = href
    @attributes = attributes
  end

  def view_template(&)
    a(href: @href, class: "text-primary hover:underline", **@attributes, &)
  end
end
