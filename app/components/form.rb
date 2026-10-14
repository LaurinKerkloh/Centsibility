class Components::Form < Components::Base
  include Phlex::Rails::Helpers::FormWith

  def initialize(model: nil, url: nil, method: nil, **attributes)
    @options = {model:, url:, method:}.compact
    @attributes = attributes
  end

  def view_template
    form_with(**@options, class: "space-y-5", **@attributes) do |form|
      @form = form
      yield self
    end
  end

  %i[text_field email_field password_field number_field file_field].each do |input|
    define_method(input) do |name, label:, **attributes|
      render Components::Field.new(form: @form, input:, name:, label:, **attributes)
    end
  end

  def select(name, choices, label:, **attributes)
    render Components::Field.new(form: @form, input: :select, name:, label:, choices:, **attributes)
  end

  def submit(text, variant: :primary)
    render Components::Button.new(variant:, type: :submit) { text }
  end
end
