class Components::Balance < Components::Base
  def initialize(balance)
    @balance = balance
  end

  def view_template
    return span(class: "text-muted") { "None" } unless @balance

    render Components::Amount.new(@balance.amount)
    plain " on #{@balance.recorded_on.to_fs(:de)}"
  end
end
