class Views::Categories::Form < Components::Base
  COLORS = Category::COLORS.map { [it.humanize, it] }.freeze

  def initialize(category:)
    @category = category
  end

  def view_template
    render Components::Form.new(model: @category, data: {controller: "category-form"}) do |form|
      form.text_field :name, label: "Name", required: true
      # Only two levels, so a category with subcategories can't get a parent.
      unless @category.subcategories?
        form.select :parent_id, @category.possible_parents.map { [it.name, it.id] }, label: "Parent",
          include_blank: true, data: {category_form_target: "parent", action: "category-form#toggle"}
      end
      # Disabled with the parent set, so a subcategory keeps its own colour.
      fieldset(data: {category_form_target: "color"}) do
        form.select :color, COLORS, label: "Colour", selected: @category.read_attribute(:color)
      end
      form.submit "Save"
    end
  end
end
