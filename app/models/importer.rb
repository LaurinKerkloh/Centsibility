class Importer
  Result = Data.define(:account, :transactions, :skipped_count, :balance)

  def initialize(statement)
    @statement = statement
  end

  def call(dry_run: false)
    account = Account.find_or_initialize_by(iban: @statement.account_iban) do |account|
      account.name = account.account_type = @statement.account_type
    end
    transactions = new_entries(account).map { build_transaction(account, it) }
    balance = Balance.find_or_initialize_by(account:, recorded_on: @statement.balance_on)
    balance.amount = @statement.balance

    unless dry_run
      ActiveRecord::Base.transaction do
        account.save!
        # Saved explicitly because belongs_to autosave silently drops an invalid new counterparty and
        # saves the transaction without it.
        transactions.filter_map(&:counterparty).uniq.each(&:save!)
        transactions.each(&:save!)
        balance.save!
      end
    end

    Result.new(account:, transactions:, skipped_count: @statement.entries.size - transactions.size, balance:)
  end

  private

  # Counts instead of a set, so a row that legitimately appears twice in a statement (two identical card
  # payments on one day) is still imported twice, while overlapping exports only add what is missing.
  def new_entries(account)
    existing = account.new_record? ? {} : account.transactions.where(raw_row: @statement.entries.map(&:raw_row)).group(:raw_row).count

    @statement.entries.reject do |entry|
      next false unless existing[entry.raw_row].to_i.positive?

      existing[entry.raw_row] -= 1
    end
  end

  def build_transaction(account, entry)
    Transaction.new(
      account:,
      counterparty: counterparty(entry.counterparty_name, entry.counterparty_iban),
      **entry.to_h.except(:counterparty_name, :counterparty_iban)
    )
  end

  def counterparty(name, iban)
    return if name.nil? && iban.nil?

    identity = Counterparty.identity(name:, iban:)
    (@counterparties ||= {})[identity] ||= Counterparty.find_or_initialize_by(identity) { it.name ||= name || iban }
  end
end
