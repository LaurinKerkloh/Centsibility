class Views::Categories::Index < Views::Base
  def initialize(categories:)
    @categories = categories
  end

  def page_title = "Categories"

  def view_template
    div(class: "w-full space-y-10") do
      div(class: "flex items-center justify-between gap-4") do
        h1(class: "text-2xl font-bold") { "Categories" }
        render Components::Button.new(href: new_category_path) { "New category" }
      end

      list
    end
  end

  private

  def list
    return p(class: "text-muted") { "No categories yet." } if @categories.empty?

    ul(class: "divide-y divide-border") do
      @categories.each do |category|
        item(category, "Delete #{category.name} and its subcategories?")
        category.subcategories.each { item(it, "Delete #{it.path}?", class: "pl-6") }
      end
    end
  end

  def item(category, confirm, **attributes)
    li(**mix({class: "flex items-center justify-between gap-4 py-2"}, attributes)) do
      render Components::CategoryBadge.new(category)

      div(class: "flex items-center gap-4") do
        render Components::Link.new(href: edit_category_path(category), class: "text-sm") { "Edit" }
        render Components::Button.new(variant: :secondary, href: category_path(category), method: :delete,
          form: {data: {turbo_confirm: confirm}}) { "Delete" }
      end
    end
  end
end
