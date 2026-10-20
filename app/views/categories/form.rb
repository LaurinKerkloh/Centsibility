class Views::Categories::Form < Components::Base
  COLORS = Category::COLORS.map { [it.humanize, it] }.freeze

  def initialize(category:)
    @category = category
  end

  def view_template
    render Components::Form.new(model: @category, data: {controller: "category-form"}) do |form|
      form.text_field :name, label: "Name", required: true
      form.select :parent_id, @category.possible_parents.map { [it.name, it.id] }, label: "Parent", include_blank: true,
        data: {category_form_target: "parent", action: "category-form#toggle"}
      div(data: {category_form_target: "color"}) do
        form.select :color, COLORS, label: "Colour"
      end
      form.submit "Save"
    end
  end
end
