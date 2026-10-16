class Components::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  INPUTS = %i[text_field email_field password_field number_field search_field date_field file_field].freeze
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

  # Segmented buttons: the radios stay focusable but invisible, their labels show the state.
  def radio_group(name, choices, label:, **attributes)
    fieldset do
      legend(class: "block text-sm font-medium") { label }

      div(class: "mt-1 inline-flex divide-x divide-border overflow-hidden rounded-md border border-border") do
        choices.each do |text, value|
          label(class: "cursor-pointer px-3 py-2 text-sm hover:bg-surface has-checked:bg-primary has-checked:text-background has-focus-visible:outline-2 has-focus-visible:-outline-offset-2 has-focus-visible:outline-primary") do
            @form.radio_button(name, value, **mix({class: "sr-only"}, attributes))
            plain text
          end
        end
      end
    end
  end

  def submit(text, variant: :primary)
    render Components::Button.new(variant:, type: :submit) { text }
  end

  private

  def field(name, label, attributes, &)
    render Components::Field.new(form: @form, name:, label:, **attributes), &
  end
end
