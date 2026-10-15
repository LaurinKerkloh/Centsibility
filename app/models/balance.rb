class Balance < ApplicationRecord
  belongs_to :account

  validates :recorded_on, presence: true, uniqueness: {scope: :account_id}
  validates :amount, numericality: true
end
