class Components::Field < Components::Base
  INPUT = "mt-1 block w-full rounded-md border bg-surface px-3 py-2 text-text shadow-sm focus:outline-2 focus:outline-primary"

  def initialize(form:, name:, label:, **attributes)
    @form = form
    @name = name
    @label = label
    @attributes = attributes
  end

  def view_template
    div do
      @form.label @name, @label, class: "block text-sm font-medium"
      yield mix(input_attributes, @attributes)

      if errors.any?
        div(id: errors_id) do
          errors.each { |message| p(class: "mt-1 text-sm text-danger") { message } }
        end
      end
    end
  end

  private

  def input_attributes
    if errors.any?
      {class: "#{INPUT} border-danger", aria: {invalid: true, describedby: errors_id}}
    else
      {class: "#{INPUT} border-border"}
    end
  end

  def errors
    @errors ||= @form.object&.errors&.full_messages_for(@name) || []
  end

  def errors_id = @form.field_id(@name, :errors)
end
