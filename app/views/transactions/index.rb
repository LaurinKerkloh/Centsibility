class Views::Transactions::Index < Views::Base
  include Phlex::Rails::Helpers::TurboFrameTag
  include Views::Transactions::Listing

  DIRECTIONS = [["All", ""], ["Income", "income"], ["Spending", "spending"]].freeze

  def initialize(filter:)
    @filter = filter
    @account = filter.account
  end

  def page_title = @account.name

  def view_template
    div(class: "w-full space-y-10") do
      h1(class: "text-2xl font-bold") { @account.name }

      filters
      turbo_frame_tag("transactions_list") { list }
    end
  end

  private

  def filters
    div(class: "flex flex-wrap items-end gap-4") do
      render Components::Form.new(model: @filter, scope: "", url: account_transactions_path(@account), method: :get,
        class!: "flex flex-wrap items-end gap-4",
        data: {controller: "auto-submit", turbo_frame: "transactions_list", turbo_action: "advance"}) do |form|
        form.search_field :q, label: "Search", data: {action: "auto-submit#debounce"}
        form.date_field :from, label: "From"
        form.date_field :to, label: "To"
        form.radio_group :direction, DIRECTIONS, label: "Direction"
      end

      if @filter.any?
        render Components::Link.new(href: account_transactions_path(@account), class: "py-2 text-sm",
          data: {turbo_frame: "_top"}) { "Clear filters" }
      end
    end
  end

  def list
    transactions = @filter.transactions
    return p(class: "text-muted") { empty_message } if transactions.empty?

    render Components::Table.new(transactions, headers: HEADERS, body_id: "transactions") { |rows, transaction| cells(rows, transaction) }
    sentinel
  end

  def empty_message = @filter.any? ? "No transactions match these filters." : "No transactions yet."
end
