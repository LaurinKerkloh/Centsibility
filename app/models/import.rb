class Import < ApplicationRecord
  belongs_to :account

  has_many :transactions
  has_many :balances
  has_many :counterparties

  attribute :file

  validates :filename, presence: true
  validates :skipped_count, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def latest? = account.imports.order(:created_at, :id).last == self

  def revert!
    transaction do
      # Without a dependent option, delete_all on the association would only nullify import_id.
      transactions.delete_all(:delete_all)
      balances.delete_all(:delete_all)
      counterparties.where.missing(:transactions).delete_all
      destroy!
      account.destroy! if created_account?
    end
  end
end
