# The next page for infinite scroll, without the layout.
class Views::Transactions::Batch < Components::Base
  include Views::Transactions::Listing

  register_element :turbo_stream

  def initialize(filter:)
    @filter = filter
  end

  def view_template
    turbo_stream(action: "append", target: "transactions") do
      template { render Components::Table::Rows.new(@filter.transactions) { |rows, transaction| cells(rows, transaction) } }
    end

    if @filter.next_page
      turbo_stream(action: "replace", target: "transactions_more") { template { sentinel } }
    else
      turbo_stream(action: "remove", target: "transactions_more")
    end
  end
end
