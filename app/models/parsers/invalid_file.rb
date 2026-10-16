module Parsers
  class InvalidFile < StandardError
    def initialize(key, **options)
      super(I18n.t(key, scope: "parsers.errors", **options))
    end
  end
end
