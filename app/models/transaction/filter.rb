class Transaction::Filter
  include ActiveModel::Model
  include ActiveModel::Attributes

  PER_PAGE = 50
  DIRECTIONS = %w[income spending].freeze

  attribute :account
  attribute :q, :string
  attribute :from, :date
  attribute :to, :date
  attribute :direction, :string
  attribute :page, :integer

  def transactions = batch.first(PER_PAGE)

  def next_page = (page_number + 1 if batch.size > PER_PAGE)

  def any? = to_params.any?

  def to_params
    {q: q.presence, from:, to:, direction: (direction if DIRECTIONS.include?(direction))}.compact
  end

  private

  # One row more than a page tells whether another page follows without counting.
  def batch
    @batch ||= filtered.order(booked_on: :desc, id: :desc)
      .offset((page_number - 1) * PER_PAGE).limit(PER_PAGE + 1).to_a
  end

  def filtered
    scope = account.transactions.includes(:counterparty)
    scope = search(scope) if q.present?
    scope = scope.where(booked_on: from..) if from
    scope = scope.where(booked_on: ..to) if to
    DIRECTIONS.include?(direction) ? scope.public_send(direction) : scope
  end

  def search(scope)
    pattern = "%#{Transaction.sanitize_sql_like(q)}%"
    # SQLite has no default escape character, so the backslashes from sanitize_sql_like need ESCAPE.
    scope.left_joins(:counterparty).where(
      "counterparties.name LIKE :pattern ESCAPE '\\' OR transactions.reference LIKE :pattern ESCAPE '\\'", pattern:
    )
  end

  def page_number = [page || 1, 1].max
end
