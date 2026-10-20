RSpec.describe Components::CategoryBadge do
  it "shows a main category's name in its colour" do
    expect(render(described_class.new(categories.living)))
      .to have_css("span.border-category-orange\\/40.bg-category-orange\\/15.text-category-orange", exact_text: "Living")
  end

  it "shows a subcategory's path in its parent's colour" do
    expect(render(described_class.new(categories.rent))).to have_css("span.text-category-orange", exact_text: "Living › Rent")
  end
end
