# Loads the next page once it scrolls into view. Renders nothing on the last page.
class Views::Transactions::More < Components::Base
  ID = "transactions_more"

  def initialize(filter)
    @filter = filter
  end

  def view_template
    return unless (page = @filter.next_page)

    url = account_transactions_path(@filter.account, **@filter.to_params, page:, format: :turbo_stream)
    div(id: ID, class: "h-px", data: {controller: "infinite-scroll", infinite_scroll_url_value: url})
  end
end
