class Transaction < ApplicationRecord
  include Paginatable

  belongs_to :account
  belongs_to :counterparty, optional: true
  belongs_to :import, optional: true
  belongs_to :category, optional: true

  validates :booked_on, :value_on, :raw_row, presence: true
  validates :amount, numericality: true

  scope :income, -> { where.not(amount: ..0) }
  scope :spending, -> { where(amount: ...0) }
  # Everything Views::Transactions::Cells shows.
  scope :for_list, -> { includes(:counterparty, category: :parent) }

  # Called on a relation, all is that relation, e.g. an account's transactions.
  def self.filtered(filter)
    filter.apply(all)
  end
end
