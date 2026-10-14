class Components::Field < Components::Base
  INPUT = "mt-1 block w-full rounded-md border bg-surface px-3 py-2 text-text shadow-sm focus:outline-2 focus:outline-primary"

  def initialize(form:, input:, name:, label:, choices: nil, **attributes)
    @form = form
    @input = input
    @name = name
    @label = label
    @choices = choices
    @attributes = attributes
  end

  def view_template
    div do
      @form.label @name, @label, class: "block text-sm font-medium"
      render_input

      if errors.any?
        div(id: errors_id) do
          errors.each { |message| p(class: "mt-1 text-sm text-danger") { message } }
        end
      end
    end
  end

  private

  def render_input
    if @input == :select
      @form.select @name, @choices, {}, **input_attributes
    else
      @form.public_send @input, @name, **input_attributes
    end
  end

  def input_attributes
    if errors.any?
      {class: "#{INPUT} border-danger", aria: {invalid: true, describedby: errors_id}, **@attributes}
    else
      {class: "#{INPUT} border-border", **@attributes}
    end
  end

  def errors
    @errors ||= @form.object&.errors&.full_messages_for(@name) || []
  end

  def errors_id = "#{@form.field_id(@name)}_errors"
end
