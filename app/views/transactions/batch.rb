# The next page for infinite scroll, without the layout.
class Views::Transactions::Batch < Components::Base
  include Phlex::Rails::Helpers::TurboStream
  include Views::Transactions::Cells

  def initialize(account:, filter:, transactions_page:)
    @account = account
    @filter = filter
    @transactions_page = transactions_page
  end

  def view_template
    turbo_stream.append("transactions") { render Components::Table::Rows.new(@transactions_page.records), &method(:cells) }
    turbo_stream.replace(Views::Transactions::More::ID) do
      render Views::Transactions::More.new(account: @account, filter: @filter, transactions_page: @transactions_page)
    end
  end
end
