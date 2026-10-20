class CategoriesController < ApplicationController
  def index
    render Views::Categories::Index.new(categories: Category.in_tree_order)
  end

  def new
    render Views::Categories::New.new(category: Category.new)
  end

  def create
    category = Category.new(category_params)

    if category.save
      redirect_to categories_path, notice: "Created #{category.name}."
    else
      render Views::Categories::New.new(category:), status: :unprocessable_content
    end
  end

  def edit
    render Views::Categories::Edit.new(category: Category.find(params[:id]))
  end

  def update
    category = Category.find(params[:id])

    if category.update(category_params)
      redirect_to categories_path, notice: "Updated #{category.name}."
    else
      render Views::Categories::Edit.new(category:), status: :unprocessable_content
    end
  end

  def destroy
    category = Category.find(params[:id])

    if category.destroy_with_subcategories
      redirect_to categories_path, notice: "Deleted #{category.name}."
    else
      redirect_to categories_path, alert: category.errors.full_messages.to_sentence
    end
  end

  private

  def category_params
    params.expect(category: %i[name parent_id color])
  end
end
