class Components::CategoryBadge < Components::Base
  BASE = "inline-flex items-center rounded-full border px-2 py-0.5 text-xs font-medium whitespace-nowrap"

  # Literal class strings, so Tailwind finds them in the source.
  COLORS = {
    "red" => "border-category-red/40 bg-category-red/15 text-category-red",
    "orange" => "border-category-orange/40 bg-category-orange/15 text-category-orange",
    "amber" => "border-category-amber/40 bg-category-amber/15 text-category-amber",
    "yellow" => "border-category-yellow/40 bg-category-yellow/15 text-category-yellow",
    "lime" => "border-category-lime/40 bg-category-lime/15 text-category-lime",
    "green" => "border-category-green/40 bg-category-green/15 text-category-green",
    "teal" => "border-category-teal/40 bg-category-teal/15 text-category-teal",
    "cyan" => "border-category-cyan/40 bg-category-cyan/15 text-category-cyan",
    "blue" => "border-category-blue/40 bg-category-blue/15 text-category-blue",
    "violet" => "border-category-violet/40 bg-category-violet/15 text-category-violet",
    "pink" => "border-category-pink/40 bg-category-pink/15 text-category-pink",
    "gray" => "border-category-gray/40 bg-category-gray/15 text-category-gray"
  }.freeze

  def initialize(category)
    @category = category
  end

  def view_template
    span(class: "#{BASE} #{COLORS.fetch(@category.color)}") { @category.path }
  end
end
