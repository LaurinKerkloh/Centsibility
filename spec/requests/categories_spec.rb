RSpec.describe "Categories" do
  let(:living) { categories.living }

  before { sign_in_as users.user }

  it "redirects to the login page when signed out" do
    delete session_path
    get categories_path

    expect(response).to redirect_to(new_session_path)
  end

  describe "GET /categories" do
    before { get categories_path }

    it "is titled Categories and links to a new category", :aggregate_failures do
      expect(response.body).to have_title("Categories")
      expect(response.body).to have_link("New category", href: new_category_path)
    end

    it "lists main categories alphabetically, each followed by its subcategories", :aggregate_failures do
      paths = Nokogiri::HTML(response.body).css("main li > span:first-child").map(&:text)

      expect(paths.first(4)).to eq(["Finance", "Finance › Bank fees", "Finance › Taxes", "Food"])
      expect(paths.size).to eq(Category.count)
    end

    it "indents subcategories and shows every category as a badge", :aggregate_failures do
      expect(response.body).to have_css("li.pl-6 span.text-category-orange", exact_text: "Living › Rent")
      expect(response.body).to have_css("li:not(.pl-6) span.text-category-orange", exact_text: "Living")
    end

    it "offers to edit and delete each category", :aggregate_failures do
      expect(response.body).to have_link("Edit", href: edit_category_path(living))
      expect(response.body).to have_css("form[action='#{category_path(living)}'][data-turbo-confirm] button", text: "Delete")
    end
  end

  it "says when there are no categories yet", :aggregate_failures do
    Transaction.update_all(category_id: nil)
    Category.tree.each(&:destroy_with_subcategories)

    get categories_path

    expect(response.body).to have_text("No categories yet.")
    expect(response.body).to have_link("New category")
  end

  describe "GET /categories/new" do
    before { get new_category_path }

    it "shows the form with name, parent and colour", :aggregate_failures do
      expect(response.body).to have_title("New category")
      expect(response.body).to have_field("Name", name: "category[name]")
      expect(response.body).to have_select("Parent", with_options: ["Living", "Food"])
      expect(response.body).to have_select("Colour", options: Category::COLORS.map(&:humanize))
    end

    it "only offers main categories as parents" do
      expect(response.body).to have_no_select("Parent", with_options: ["Rent"])
    end

    it "wires the colour toggle", :aggregate_failures do
      expect(response.body).to have_css("form[data-controller='category-form'] select[data-category-form-target='parent']")
      expect(response.body).to have_css("div[data-category-form-target='color'] select#category_color")
    end
  end

  describe "POST /categories" do
    it "creates the category and redirects to the list", :aggregate_failures do
      expect { post categories_path, params: {category: {name: "Pets", color: "red"}} }.to change(Category, :count).by(1)

      expect(response).to redirect_to(categories_path)
      expect(flash[:notice]).to eq("Created Pets.")
    end

    it "creates a subcategory" do
      post categories_path, params: {category: {name: "Vet", parent_id: categories.health.id}}

      expect(Category.find_by(name: "Vet").parent).to eq(categories.health)
    end

    it "shows the errors", :aggregate_failures do
      post categories_path, params: {category: {name: "rent", parent_id: living.id}}

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to have_css("#category_name_errors", text: "Name has already been taken")
    end
  end

  describe "GET /categories/:id/edit" do
    it "shows the form without the category itself as a parent", :aggregate_failures do
      get edit_category_path(living)

      expect(response.body).to have_title("Edit Living")
      expect(response.body).to have_field("Name", with: "Living")
      expect(response.body).to have_no_select("Parent", with_options: ["Living"])
    end
  end

  describe "PATCH /categories/:id" do
    it "updates the category", :aggregate_failures do
      patch category_path(categories.rent), params: {category: {name: "Rent & fees"}}

      expect(response).to redirect_to(categories_path)
      expect(categories.rent.reload.name).to eq("Rent & fees")
    end

    it "shows the errors" do
      patch category_path(living), params: {category: {parent_id: categories.food.id}}

      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe "DELETE /categories/:id" do
    it "deletes an unused category with its subcategories", :aggregate_failures do
      expect { delete category_path(categories.health) }.to change(Category, :count).by(-3)

      expect(response).to redirect_to(categories_path)
      expect(flash[:notice]).to eq("Deleted Health.")
    end

    it "keeps a category in use", :aggregate_failures do
      transactions.salary.update!(category: categories.rent)

      expect { delete category_path(living) }.not_to change(Category, :count)
      expect(response).to redirect_to(categories_path)
      expect(flash[:alert]).to eq("Living or one of its subcategories is still used by transactions.")
    end
  end
end
