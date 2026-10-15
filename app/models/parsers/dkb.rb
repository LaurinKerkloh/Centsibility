module Parsers
  class Dkb
    COLUMNS = [
      "Buchungsdatum", "Wertstellung", "Status", "Zahlungspflichtige*r", "Zahlungsempfänger*in", "Verwendungszweck",
      "Umsatztyp", "IBAN", "Betrag (€)", "Gläubiger-ID", "Mandatsreferenz", "Kundenreferenz"
    ].freeze
    HEADER_LINES = 5
    # DKB fills the IBAN column with these when there is no real counterparty account, e.g. for its own fees
    # and for card payments, which all run through its VISA clearing account.
    PLACEHOLDER_IBANS = %w[0000000000 DE96120300009005290904].freeze
    BALANCE_LABEL = /\AKontostand vom (\d{2}\.\d{2}\.\d{4}):\z/
    ROW_DATE = /\A\d{2}\.\d{2}\.\d{2}\z/
    AMOUNT = /\A-?\d{1,3}(\.\d{3})*(,\d{1,2})?\z|\A-?\d+(,\d{1,2})?\z/

    def self.parse(content) = new(content).parse

    def initialize(content)
      @content = content
    end

    def parse
      lines = utf8_lines
      raise InvalidFile, "The file is missing the DKB header block." if lines.size < HEADER_LINES

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
      raise InvalidFile, "The file is not valid UTF-8 text. Upload the CSV export unchanged." unless content.valid_encoding?

      content.delete_prefix("\uFEFF").each_line(chomp: true).to_a
    end

    def account_line(line)
      fields = fields(line, 1)
      raise InvalidFile, "Line 1: expected the account type and IBAN." unless fields.size == 2 && fields.all?(&:present?)

      fields
    end

    def balance_line(line)
      label, amount = fields(line, 3)
      raise InvalidFile, "Line 3: expected \"Kontostand vom DD.MM.YYYY:\"." unless (match = BALANCE_LABEL.match(label))

      [date(match[1], "%d.%m.%Y", 3), amount(amount.to_s.sub(/[[:space:]]*€\z/, ""), 3)]
    end

    def column_line(line)
      return if fields(line, 5) == COLUMNS

      raise InvalidFile, "Line 5: unexpected column headers. Only DKB account exports are supported."
    end

    def entry(line, number)
      fields = fields(line, number)
      raise InvalidFile, "Line #{number}: expected #{COLUMNS.size} fields, got #{fields.size}." unless fields.size == COLUMNS.size

      booked_on, value_on, status, payer, payee, reference, _type, iban, amount, creditor_id, mandate_reference,
        customer_reference = fields.map(&:presence)

      return if status == "Vorgemerkt"
      raise InvalidFile, "Line #{number}: unknown status #{status.inspect}." unless status == "Gebucht"

      amount = amount(amount, number)

      Entry.new(
        booked_on: row_date(booked_on, number),
        value_on: row_date(value_on, number),
        amount:,
        counterparty_name: amount.negative? ? payee : payer,
        counterparty_iban: (iban unless PLACEHOLDER_IBANS.include?(iban)),
        reference:, creditor_id:, mandate_reference:, customer_reference:,
        raw_row: line
      )
    end

    def fields(line, number)
      CSV.parse_line(line, col_sep: ";") || []
    rescue CSV::MalformedCSVError => error
      raise InvalidFile, "Line #{number}: #{error.message}"
    end

    def row_date(value, number)
      raise InvalidFile, "Line #{number}: unreadable date #{value.inspect}." unless ROW_DATE.match?(value.to_s)

      date(value, "%d.%m.%y", number)
    end

    def date(value, format, number)
      Date.strptime(value, format)
    rescue Date::Error
      raise InvalidFile, "Line #{number}: unreadable date #{value.inspect}."
    end

    def amount(value, number)
      raise InvalidFile, "Line #{number}: unreadable amount #{value.inspect}." unless AMOUNT.match?(value.to_s)

      BigDecimal(value.delete(".").tr(",", "."))
    end
  end
end
