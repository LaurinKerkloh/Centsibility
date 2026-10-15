class Importer
  Result = Data.define(:import, :account, :transactions, :skipped_count, :balance)

  def initialize(statement)
    @statement = statement
  end

  def call(import:)
    account = Account.find_or_initialize_by(iban: @statement.account_iban) do |account|
      account.name = account.account_type = @statement.account_type
    end
    created_account = account.new_record?
    transactions = new_entries(account).map { build_transaction(account, it) }
    skipped_count = @statement.entries.size - transactions.size
    balance = build_balance(account)

    if transactions.empty? && balance.nil?
      import = nil
    else
      import.assign_attributes(account:, skipped_count:, created_account:)
      # Counterparties are saved explicitly because belongs_to autosave silently drops an invalid new one
      # and saves the transaction without it.
      counterparties = @counterparties.to_h.values.select(&:new_record?)
      [*counterparties, *transactions, balance].compact.each { it.import = import }

      ActiveRecord::Base.transaction do
        [account, import, *counterparties, *transactions, balance].compact.each(&:save!)
      end
    end

    Result.new(import:, account:, transactions:, skipped_count:, balance:)
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
    (@counterparties ||= {})[identity] ||= Counterparty.find_or_initialize_by(identity) { it.name ||= name || identity[:iban] }
  end

  def build_balance(account)
    return if !account.new_record? && account.balance_on(@statement.balance_on)&.amount == @statement.balance

    Balance.new(account:, recorded_on: @statement.balance_on, amount: @statement.balance)
  end
end
