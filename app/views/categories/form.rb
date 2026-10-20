class Views::Categories::Form < Components::Base
  COLORS = Category::COLORS.map { [it.humanize, it] }.freeze

  def initialize(category:)
    @category = category
  end

  def view_template
    render Components::Form.new(model: @category, data: {controller: "category-form"}) do |form|
      form.text_field :name, label: "Name", required: true
      form.select :parent_id, parents, label: "Parent", include_blank: true,
        data: {category_form_target: "parent", action: "category-form#toggle"}
      # Subcategories take their parent's colour.
      div(data: {category_form_target: "color"}) do
        form.select :color, COLORS, label: "Colour"
      end
      form.submit "Save"
    end
  end

  private

  def parents
    Category.main.where.not(id: @category.id).order(:name).map { [it.name, it.id] }
  end
end
