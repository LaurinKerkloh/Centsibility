class Importer
  Result = Data.define(:account, :transactions, :skipped_count, :balance)

  def initialize(statement)
    @statement = statement
  end

  def call(dry_run: false)
    account = Account.find_or_initialize_by(iban: @statement.account_iban) do |account|
      account.name = account.account_type = @statement.account_type
    end
    entries, skipped_count = new_entries(account)
    transactions = entries.map { build_transaction(account, it) }
    balance = build_balance(account)

    unless dry_run
      ActiveRecord::Base.transaction do
        account.save!
        transactions.each { it.counterparty&.save! }
        transactions.each(&:save!)
        balance.save!
      end
    end

    Result.new(account:, transactions:, skipped_count:, balance:)
  end

  private

  # Counts instead of a set, so a row that legitimately appears twice in a statement (two identical card
  # payments on one day) is still imported twice, while overlapping exports only add what is missing.
  def new_entries(account)
    existing = account.new_record? ? {} : account.transactions.where(raw_row: @statement.entries.map(&:raw_row)).group(:raw_row).count
    skipped_count = 0

    entries = @statement.entries.reject do |entry|
      next false unless existing[entry.raw_row].to_i.positive?

      existing[entry.raw_row] -= 1
      skipped_count += 1
    end

    [entries, skipped_count]
  end

  def build_transaction(account, entry)
    Transaction.new(
      account:,
      counterparty: counterparty(entry.counterparty_name, entry.counterparty_iban),
      **entry.to_h.slice(:booked_on, :value_on, :amount, :reference, :creditor_id, :mandate_reference, :customer_reference, :raw_row)
    )
  end

  def counterparty(name, iban)
    return if name.nil? && iban.nil?

    @counterparties ||= {}
    @counterparties[iban || [:name, name]] ||=
      if iban
        Counterparty.find_or_initialize_by(iban:) { it.name = name || iban }
      else
        Counterparty.find_or_initialize_by(iban: nil, name:)
      end
  end

  def build_balance(account)
    Balance.find_or_initialize_by(account:, recorded_on: @statement.balance_on).tap { it.amount = @statement.balance }
  end
end
