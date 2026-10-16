# Loads the next page once it scrolls into view. After the last page it marks the end, unless the whole list fit
# into one batch.
class Views::Transactions::More < Components::Base
  ID = "transactions_more"

  def initialize(filter)
    @filter = filter
  end

  def view_template
    if (page = @filter.next_page)
      url = account_transactions_path(@filter.account, **@filter.to_params, page:, format: :turbo_stream)
      div(id: ID, class: "h-px", data: {controller: "infinite-scroll", infinite_scroll_url_value: url})
    elsif !@filter.first_page?
      p(class: "py-4 text-center text-sm text-muted") { "No more transactions." }
    end
  end
end
