class Views::Transactions::Index < Views::Base
  include Phlex::Rails::Helpers::TurboFrameTag
  include Views::Transactions::Cells

  DIRECTIONS = [["All", ""], *Transaction::Filter::DIRECTIONS.map { [it.humanize, it] }].freeze

  def initialize(account:, filter:, transactions_page:)
    @account = account
    @filter = filter
    @transactions_page = transactions_page
  end

  def page_title = @account.name

  def view_template
    div(class: "w-full space-y-10") do
      h1(class: "text-2xl font-bold") { @account.name }

      filters
      turbo_frame_tag("transactions_list", class: "block space-y-4") { list }
    end
  end

  private

  def filters
    render Components::Form.new(model: @filter, scope: "", url: account_transactions_path(@account), method: :get,
      class!: "flex flex-wrap items-end gap-4",
      data: {controller: "auto-submit date-range", turbo_frame: "transactions_list", turbo_action: "advance",
             action: "change->auto-submit#submit formdata->auto-submit#dropBlank"}) do |form|
      form.search_field :q, label: "Search", data: {action: "auto-submit#debounce"}
      # Chrome fires change for every digit of the year, so dates wait like the search does.
      form.date_field :from, label: "From", max: @filter.to,
        data: {date_range_target: "from", action: "change->date-range#sync change->auto-submit#debounce:stop"}
      form.date_field :to, label: "To", min: @filter.from,
        data: {date_range_target: "to", action: "change->date-range#sync change->auto-submit#debounce:stop"}
      form.radio_group :direction, DIRECTIONS, label: "Direction"
    end
  end

  # Inside the frame, so it shows up and goes away as the filters change. It leaves the frame to reset the form too.
  def clear_filters
    return unless @filter.any?

    render Components::Link.new(href: account_transactions_path(@account), class: "text-sm",
      data: {turbo_frame: "_top"}) { "Clear filters" }
  end

  def list
    clear_filters
    return p(class: "text-muted") { empty_message } if @transactions_page.records.empty?

    render Components::Table.new(@transactions_page.records, headers: HEADERS, body: {id: "transactions"}), &method(:cells)
    render Views::Transactions::More.new(account: @account, filter: @filter, transactions_page: @transactions_page)
  end

  def empty_message = @filter.any? ? "No transactions match these filters." : "No transactions yet."
end
