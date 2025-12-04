class MenuItemsController < ApplicationController
  before_action :set_menu_category
  before_action :set_restaurant_from_params, only: [:new, :create]

  def index
    # lista universal de items para esa categoría (opcional)
    @menu_items = @menu_category.menu_items
  end

  def new
    # pre-asigna restaurant si viene por params
    @menu_item = MenuItem.new(menu_category: @menu_category)
    @menu_item.restaurant = @restaurant if @restaurant.present?
  end

  def create
    @menu_item = MenuItem.new(menu_item_params)
    @menu_item.menu_category = @menu_category

    # si el restaurant_id viene por params, asociarlo
    if params[:menu_item] && params[:menu_item][:restaurant_id].present?
      @menu_item.restaurant_id = params[:menu_item][:restaurant_id]
    end

    # proteger: verificar que la categoría esté habilitada para el restaurante
    if @menu_item.restaurant.present? && !@menu_item.restaurant.menu_category_ids.include?(@menu_category.id)
      @menu_item.errors.add(:menu_category, "no está habilitada para ese restaurante")
      render :new, status: :unprocessable_entity and return
    end

    if @menu_item.save
      # redirige donde prefieras: al restaurante o a la categoría
      redirect_to restaurant_path(@menu_item.restaurant), notice: "Platillo creado correctamente."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @menu_item = @menu_category.menu_items.find(params[:id])
    # o: @menu_item = MenuItem.find(params[:id])
  end

  def update
    @menu_item = @menu_category.menu_items.find(params[:id])
    if @menu_item.update(menu_item_params)
      redirect_to restaurant_path(@menu_item.restaurant), notice: "Platillo actualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu_item = @menu_category.menu_items.find(params[:id])
    restaurant = @menu_item.restaurant
    @menu_item.destroy
    redirect_to restaurant_path(restaurant), notice: "Platillo eliminado."
  end

  private

  def set_menu_category
    @menu_category = MenuCategory.find(params[:menu_category_id])
  end

  def set_restaurant_from_params
    return unless params[:restaurant_id].present?
    @restaurant = Restaurant.find_by(id: params[:restaurant_id])

    # opcional: si no existe redirigir o lanzar error
    unless @restaurant
      redirect_to menu_category_path(@menu_category), alert: "Restaurante no encontrado." and return
    end
  end

  def menu_item_params
    params.require(:menu_item).permit(:name, :description, :price, :photo, :visible, :spicy_level, :restaurant_id, :is_special)
  end
end
