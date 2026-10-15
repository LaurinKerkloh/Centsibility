class Balance < ApplicationRecord
  belongs_to :account
  belongs_to :import, optional: true

  validates :recorded_on, presence: true
  validates :amount, numericality: true
end
