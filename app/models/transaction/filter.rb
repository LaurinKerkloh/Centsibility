class Transaction::Filter
  include ActiveModel::Model
  include ActiveModel::Attributes

  DIRECTIONS = %w[income spending].freeze

  attribute :q, :string
  attribute :from, :date
  attribute :to, :date
  attribute :direction, :string

  def apply(scope)
    scope = search(scope) if q.present?
    scope = scope.where(booked_on: from..) if from
    scope = scope.where(booked_on: ..to) if to
    scope = scope.public_send(direction) if DIRECTIONS.include?(direction)
    scope.order(booked_on: :desc, id: :desc)
  end

  def any?
    to_params.any?
  end

  def to_params
    {q: q.presence, from:, to:, direction: (direction if DIRECTIONS.include?(direction))}.compact
  end

  private

  def search(scope)
    pattern = "%#{Transaction.sanitize_sql_like(q)}%"
    # SQLite has no default escape character, so the backslashes from sanitize_sql_like need ESCAPE.
    scope.left_joins(:counterparty).where(
      "counterparties.name LIKE :pattern ESCAPE '\\' OR transactions.reference LIKE :pattern ESCAPE '\\'", pattern:
    )
  end
end
