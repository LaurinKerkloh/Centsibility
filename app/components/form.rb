class Components::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  INPUTS = %i[text_field email_field password_field number_field file_field].freeze
  SELECT_OPTIONS = %i[include_blank prompt selected].freeze

  def initialize(**options)
    @options = options
  end

  def view_template
    form_with(**mix({class: "space-y-5"}, @options)) do |form|
      @form = form
      yield self
    end
  end

  INPUTS.each do |input|
    define_method(input) do |name, label:, **attributes|
      field(name, label, attributes) { |input_attributes| @form.public_send(input, name, **input_attributes) }
    end
  end

  def select(name, choices, label:, **attributes)
    options = attributes.extract!(*SELECT_OPTIONS)
    field(name, label, attributes) { |input_attributes| @form.select(name, choices, options, **input_attributes) }
  end

  def submit(text, variant: :primary)
    render Components::Button.new(variant:, type: :submit) { text }
  end

  private

  def field(name, label, attributes, &)
    render Components::Field.new(form: @form, name:, label:, **attributes), &
  end
end
