class Components::Amount < Components::Base
  include Phlex::Rails::Helpers::NumberToCurrency

  def initialize(amount)
    @amount = amount
  end

  def view_template
    span(class: "whitespace-nowrap tabular-nums") do
      number_to_currency(@amount, unit: "€", separator: ",", delimiter: ".", format: "%n %u")
    end
  end
end
