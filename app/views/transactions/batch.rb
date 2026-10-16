# The next page for infinite scroll, without the layout.
class Views::Transactions::Batch < Components::Base
  include Phlex::Rails::Helpers::TurboStream
  include Views::Transactions::Cells

  def initialize(filter:)
    @filter = filter
  end

  def view_template
    turbo_stream.append("transactions") { render Components::Table::Rows.new(@filter.transactions), &method(:cells) }
    turbo_stream.replace(Views::Transactions::More::ID) { render Views::Transactions::More.new(@filter) }
  end
end
