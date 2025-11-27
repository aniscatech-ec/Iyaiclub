class MenuCategoriesController < ApplicationController
  # before_action :set_menu_category, only: [:show, :edit, :update, :destroy]

  def index
    @menu_categories = MenuCategory.all
  end

  def new
    @menu_category = MenuCategory.new
  end

  def create
    @menu_category = MenuCategory.new(menu_category_params)
    if @menu_category.save
      redirect_to menu_categories_path, notice: "Categoría creada correctamente."
    else
      render :new
    end
  end

  def edit; end

  def update
    if @menu_category.update(menu_category_params)
      redirect_to menu_categories_path, notice: "Categoría actualizada."
    else
      render :edit
    end
  end

  def destroy
    @menu_category.destroy
    redirect_to menu_categories_path, notice: "Categoría eliminada."
  end

  private

  def set_menu_category
    @menu_category = MenuCategory.find(params[:id])
  end

  def menu_category_params
    params.require(:menu_category).permit(:name, :description)
  end
end
