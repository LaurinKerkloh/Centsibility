class Import < ApplicationRecord
  belongs_to :account

  has_many :transactions
  has_many :balances
  has_many :counterparties

  attribute :file

  scope :with_new_count, -> { left_joins(:transactions).group(:id).select("imports.*, COUNT(transactions.id) AS new_count") }

  validates :filename, presence: true
  validates :skipped_count, numericality: {only_integer: true, greater_than_or_equal_to: 0}

  def self.from_file(file:)
    import = new(filename: file.try(:original_filename))
    return import.tap { it.errors.add(:file, :missing) } unless file.respond_to?(:read)

    result = Importer.new(Parsers::Dkb.parse(file.read)).call(import:)
    import.errors.add(:file, :nothing_new, filename: import.filename) unless result.import
    import
  rescue Parsers::InvalidFile, ActiveRecord::RecordInvalid => error
    import.tap { it.errors.add(:file, error.message) }
  end

  def latest? = account.imports.maximum(:id) == id

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
