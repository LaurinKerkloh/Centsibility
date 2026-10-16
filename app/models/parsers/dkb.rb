module Parsers
  class Dkb
    COLUMNS = [
      "Buchungsdatum", "Wertstellung", "Status", "Zahlungspflichtige*r", "Zahlungsempfänger*in", "Verwendungszweck",
      "Umsatztyp", "IBAN", "Betrag (€)", "Gläubiger-ID", "Mandatsreferenz", "Kundenreferenz"
    ].freeze
    HEADER_LINES = 5
    # Card payments all run through DKB's VISA clearing account, so its IBAN says nothing about the counterparty.
    PLACEHOLDER_IBANS = %w[DE96120300009005290904].freeze
    # For its own fees and settlements DKB puts internal account numbers (or 0000000000) in the IBAN column.
    # They are shared by many bookings and stay available in raw_row.
    IBAN_SHAPE = /\A[A-Z]{2}\d{2}/
    # Card bookings name "ISSUER" as payer in both directions, with the merchant as payee. Their IBAN column
    # holds a clearing or own account, never the merchant's.
    CARD_ISSUER = "ISSUER"
    BALANCE_LABEL = /\AKontostand vom (\d{2}\.\d{2}\.\d{4}):\z/
    ROW_DATE = /\A\d{2}\.\d{2}\.\d{2}\z/
    AMOUNT = /\A-?\d{1,3}(\.\d{3})*(,\d{1,2})?\z|\A-?\d+(,\d{1,2})?\z/

    def self.parse(content) = new(content).parse

    def initialize(content)
      @content = content
    end

    def parse
      lines = utf8_lines
      raise InvalidFile, :missing_header if lines.size < HEADER_LINES

      account_type, account_iban = account_line(lines[0])
      balance_on, balance = balance_line(lines[2])
      column_line(lines[4])

      entries = lines.drop(HEADER_LINES).each.with_index(HEADER_LINES + 1).filter_map do |line, number|
        entry(line, number) unless line.empty?
      end

      Statement.new(account_iban:, account_type:, balance:, balance_on:, entries:)
    end

    private

    def utf8_lines
      content = @content.dup.force_encoding(Encoding::UTF_8)
      raise InvalidFile, :invalid_encoding unless content.valid_encoding?

      content.delete_prefix("\uFEFF").each_line(chomp: true).to_a
    end

    def account_line(line)
      fields = fields(line, 1)
      raise InvalidFile, :account_line unless fields.size == 2 && fields.all?(&:present?)

      fields
    end

    def balance_line(line)
      label, amount = fields(line, 3)
      raise InvalidFile, :balance_line unless (match = BALANCE_LABEL.match(label))

      [date(match[1], "%d.%m.%Y", 3), amount(amount.to_s.sub(/[[:space:]]*€\z/, ""), 3)]
    end

    def column_line(line)
      return if fields(line, 5) == COLUMNS

      raise InvalidFile, :column_line
    end

    def entry(line, number)
      fields = fields(line, number)
      raise InvalidFile.new(:field_count, line: number, expected: COLUMNS.size, actual: fields.size) unless fields.size == COLUMNS.size

      booked_on, value_on, status, payer, payee, reference, _type, iban, amount, creditor_id, mandate_reference,
        customer_reference = fields.map(&:presence)

      return if status == "Vorgemerkt"
      raise InvalidFile.new(:unknown_status, line: number, status:) unless status == "Gebucht"

      amount = amount(amount, number)
      card = payer == CARD_ISSUER

      Entry.new(
        booked_on: row_date(booked_on, number),
        value_on: row_date(value_on, number),
        amount:,
        counterparty_name: (amount.negative? || card) ? payee : payer,
        counterparty_iban: (iban if !card && IBAN_SHAPE.match?(iban.to_s) && !PLACEHOLDER_IBANS.include?(iban)),
        reference:, creditor_id:, mandate_reference:, customer_reference:,
        raw_row: line
      )
    end

    def fields(line, number)
      CSV.parse_line(line, col_sep: ";") || []
    rescue CSV::MalformedCSVError => error
      raise InvalidFile.new(:malformed_line, line: number, details: error.message)
    end

    def row_date(value, number)
      raise InvalidFile.new(:unreadable_date, line: number, value:) unless ROW_DATE.match?(value.to_s)

      date(value, "%d.%m.%y", number)
    end

    def date(value, format, number)
      Date.strptime(value, format)
    rescue Date::Error
      raise InvalidFile.new(:unreadable_date, line: number, value:)
    end

    def amount(value, number)
      raise InvalidFile.new(:unreadable_amount, line: number, value:) unless AMOUNT.match?(value.to_s)

      BigDecimal(value.delete(".").tr(",", "."))
    end
  end
end
