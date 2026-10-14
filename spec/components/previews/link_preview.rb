class LinkPreview < Lookbook::Preview
  def default
    render Components::Link.new(href: "#") { "Forgot password?" }
  end

  # @param text text
  # @param href text
  def playground(text: "Link", href: "#")
    render Components::Link.new(href:) { text }
  end
end
