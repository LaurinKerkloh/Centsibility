class Category < ApplicationRecord
  COLORS = %w[red orange amber yellow lime green teal cyan blue violet pink gray].freeze

  belongs_to :parent, class_name: "Category", optional: true
  has_many :subcategories, -> { order(:name) }, class_name: "Category", foreign_key: :parent_id, inverse_of: :parent
  has_many :transactions, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: {scope: :parent_id, case_sensitive: false}
  validates :color, inclusion: {in: COLORS}, unless: :parent
  validate :two_levels_only

  scope :main, -> { where(parent_id: nil) }

  def self.tree = main.includes(:subcategories).order(:name)

  # A subcategory's own colour is kept for when it becomes a main category again.
  def color = parent ? parent.color : super

  def path = parent ? "#{parent.name} › #{name}" : name

  def self_and_subcategory_ids = [id, *subcategory_ids]

  def destroy_with_subcategories
    if Transaction.exists?(category_id: self_and_subcategory_ids)
      errors.add(:base, :in_use, name: path)
      return false
    end

    transaction do
      subcategories.each(&:destroy!)
      destroy!
    end
    true
  end

  private

  def two_levels_only
    return unless parent

    if parent == self
      errors.add(:parent, :self)
    elsif parent.parent_id
      errors.add(:parent, :not_main)
    elsif persisted? && subcategories.exists?
      errors.add(:parent, :has_subcategories)
    end
  end
end
