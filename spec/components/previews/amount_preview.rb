class AmountPreview < Lookbook::Preview
  def negative
    render Components::Amount.new(BigDecimal("-6.9"))
  end

  def positive
    render Components::Amount.new(BigDecimal("1616.35"))
  end

  # @param amount number
  def playground(amount: 1616.35)
    render Components::Amount.new(BigDecimal(amount.to_s))
  end
end
