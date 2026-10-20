class Transaction::Filter
  include ActiveModel::Model
  include ActiveModel::Attributes

  DIRECTIONS = %w[income spending].freeze

  attribute :q, :string
  attribute :from, :date
  attribute :to, :date
  attribute :direction, :string
  attribute :category, :string

  def apply(scope)
    scope = search(scope) if q.present?
    scope = scope.where(booked_on: from..) if from
    scope = scope.where(booked_on: ..to) if to
    scope = scope.public_send(direction) if DIRECTIONS.include?(direction)
    scope = scope.where(category_id: category_ids) if category_ids
    scope.order(booked_on: :desc, id: :desc)
  end

  def any?
    to_params.any?
  end

  def to_params
    {q: q.presence, from:, to:, direction: (direction if DIRECTIONS.include?(direction)),
     category: (category if category_ids)}.compact
  end

  def category_choices
    [["All categories", ""], ["Uncategorised", "none"],
      *Category.tree.flat_map { |main| [main, *main.subcategories] }.map { [it.path, it.id] }]
  end

  private

  # nil when no category, or an unknown one, is selected.
  def category_ids
    return @category_ids if defined?(@category_ids)

    @category_ids = if category == "none"
      [nil]
    elsif category.present?
      Category.find_by(id: category)&.self_and_subcategory_ids
    end
  end

  def search(scope)
    pattern = "%#{Transaction.sanitize_sql_like(q)}%"
    # SQLite has no default escape character, so the backslashes from sanitize_sql_like need ESCAPE.
    scope.left_joins(:counterparty).where(
      "counterparties.name LIKE :pattern ESCAPE '\\' OR transactions.reference LIKE :pattern ESCAPE '\\'", pattern:
    )
  end
end
