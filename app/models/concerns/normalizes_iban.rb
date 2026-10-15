module NormalizesIban
  extend ActiveSupport::Concern

  included do
    # Blank becomes nil so the partial unique indexes on iban IS NULL apply. [[:space:]] also covers the
    # non-breaking spaces that come with IBANs copied from banking web pages.
    normalizes :iban, with: ->(iban) { iban.gsub(/[[:space:]]/, "").upcase.presence }
  end
end
