RSpec.describe Category do
  let(:living) { categories.living }
  let(:rent) { categories.rent }

  def build(**attributes) = described_class.new(name: "Pets", color: "red", **attributes)

  it "is valid as a main category with a name and a colour" do
    expect(build).to be_valid
  end

  it "requires a name" do
    expect(build(name: "")).not_to be_valid
  end

  describe "name uniqueness" do
    it "rejects a sibling's name in any case", :aggregate_failures do
      expect(build(name: "rent", parent: living)).not_to be_valid
      expect(build(name: "living")).not_to be_valid
    end

    it "allows the name under another parent or at the top level", :aggregate_failures do
      expect(build(name: "Rent", parent: categories.food)).to be_valid
      expect(build(name: "Rent")).to be_valid
    end

    it "is enforced in the database for subcategories and main categories", :aggregate_failures do
      expect { build(name: "rent", parent: living).save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
      expect { build(name: "living").save(validate: false) }.to raise_error(ActiveRecord::RecordNotUnique)
    end
  end

  describe "two levels only" do
    it "requires the parent to be a main category", :aggregate_failures do
      category = build(parent: rent)

      expect(category).not_to be_valid
      expect(category.errors).to be_of_kind(:parent, :not_main)
    end

    it "rejects the category as its own parent", :aggregate_failures do
      living.parent = living

      expect(living).not_to be_valid
      expect(living.errors).to be_of_kind(:parent, :self)
    end

    it "rejects a parent for a category with subcategories", :aggregate_failures do
      living.parent = categories.food

      expect(living).not_to be_valid
      expect(living.errors).to be_of_kind(:parent, :has_subcategories)
    end
  end

  describe "colour" do
    it "is required for main categories and has to be in the palette", :aggregate_failures do
      expect(build(color: nil)).not_to be_valid
      expect(build(color: "magenta")).not_to be_valid
    end

    it "is inherited by subcategories, ignoring their own", :aggregate_failures do
      category = build(color: "magenta", parent: living)

      expect(category).to be_valid
      expect(category.color).to eq("orange")
    end

    it "is kept on a subcategory for when it becomes a main category again" do
      category = build(color: "blue", parent: living)
      category.save!
      category.update!(parent: nil)

      expect(category.color).to eq("blue")
    end
  end

  describe "#path" do
    it "joins the parent's name and the name for subcategories", :aggregate_failures do
      expect(rent.path).to eq("Living › Rent")
      expect(living.path).to eq("Living")
    end
  end

  describe ".tree" do
    it "lists main categories alphabetically with their subcategories alphabetically", :aggregate_failures do
      tree = described_class.tree

      expect(tree.map(&:name)).to eq(tree.map(&:name).sort)
      expect(tree.find { it.name == "Living" }.subcategories.map(&:name))
        .to eq(["Household", "Internet & phone", "Rent", "Utilities"])
    end
  end

  describe ".in_tree_order" do
    it "puts each main category before its subcategories" do
      expect(described_class.in_tree_order.first(4).map(&:path))
        .to eq(["Finance", "Finance › Bank fees", "Finance › Taxes", "Food"])
    end
  end

  describe "#possible_parents" do
    it "offers main categories other than the category itself", :aggregate_failures do
      expect(categories.living.possible_parents).to include(categories.food).and exclude(categories.living, categories.rent)
      expect(described_class.new.possible_parents).to include(categories.living)
    end
  end

  describe "#self_and_subcategory_ids" do
    it "includes the subcategories", :aggregate_failures do
      expect(living.self_and_subcategory_ids).to contain_exactly(living.id, *living.subcategories.ids)
      expect(rent.self_and_subcategory_ids).to eq([rent.id])
    end
  end

  describe "#destroy_with_subcategories" do
    it "deletes an unused subcategory", :aggregate_failures do
      household = categories.household

      expect(household.destroy_with_subcategories).to be(true)
      expect(described_class.exists?(household.id)).to be(false)
    end

    it "deletes a main category with its unused subcategories" do
      expect { categories.health.destroy_with_subcategories }.to change(described_class, :count).by(-3)
    end

    it "keeps a used category", :aggregate_failures do
      transactions.salary.update!(category: rent)

      expect { rent.destroy_with_subcategories }.not_to change(described_class, :count)
      expect(rent.errors.full_messages).to eq(["Living › Rent or one of its subcategories is still used by transactions."])
    end

    it "keeps a main category and all its subcategories when one of them is used", :aggregate_failures do
      transactions.salary.update!(category: rent)

      expect { expect(living.destroy_with_subcategories).to be(false) }.not_to change(described_class, :count)
      expect(living.errors.full_messages).to eq(["Living or one of its subcategories is still used by transactions."])
    end
  end
end
