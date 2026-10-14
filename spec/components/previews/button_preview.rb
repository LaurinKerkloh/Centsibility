class ButtonPreview < Lookbook::Preview
  def primary
    render Components::Button.new { "Save" }
  end

  def secondary
    render Components::Button.new(variant: :secondary) { "Cancel" }
  end

  def danger
    render Components::Button.new(variant: :danger) { "Delete" }
  end

  def as_link
    render Components::Button.new(variant: :secondary, href: "#") { "New rule" }
  end

  def as_button_to
    render Components::Button.new(variant: :secondary, href: "#", method: :delete) { "Sign out" }
  end

  # @param variant select [primary, secondary, danger]
  # @param text text
  def playground(variant: :primary, text: "Button")
    render Components::Button.new(variant: variant.to_sym) { text }
  end
end
