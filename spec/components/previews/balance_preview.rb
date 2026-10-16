class BalancePreview < Lookbook::Preview
  def default
    render Components::Balance.new(Balance.new(amount: BigDecimal("1616.35"), recorded_on: Date.new(2026, 10, 14)))
  end

  def none
    render Components::Balance.new(nil)
  end
end
