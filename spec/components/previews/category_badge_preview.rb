class CategoryBadgePreview < Lookbook::Preview
  class Palette < Components::Base
    def view_template
      div(class: "flex flex-wrap gap-2") do
        Category::COLORS.each { render Components::CategoryBadge.new(Category.new(name: it.capitalize, color: it)) }
      end
    end
  end

  def main_category
    render Components::CategoryBadge.new(Category.new(name: "Living", color: "orange"))
  end

  def subcategory
    render Components::CategoryBadge.new(Category.new(name: "Rent", parent: Category.new(name: "Living", color: "orange")))
  end

  def palette
    render Palette.new
  end
end
