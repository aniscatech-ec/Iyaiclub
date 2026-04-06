class DropOldMenuTables < ActiveRecord::Migration[8.0]
  def up
    # Eliminar foreign keys antes de borrar tablas
    if table_exists?(:restaurant_menu_categories)
      remove_foreign_key :restaurant_menu_categories, :restaurants, if_exists: true
      remove_foreign_key :restaurant_menu_categories, :menu_categories, if_exists: true
    end

    if table_exists?(:menu_options)
      remove_foreign_key :menu_options, :menu_items, if_exists: true
    end

    if table_exists?(:menu_items)
      remove_foreign_key :menu_items, :restaurants, if_exists: true
      remove_foreign_key :menu_items, :menu_categories, if_exists: true
    end

    # Ahora sí eliminar tablas en orden seguro
    drop_table :restaurant_menu_categories, if_exists: true
    drop_table :menu_options, if_exists: true
    drop_table :menu_items, if_exists: true
    drop_table :menu_categories, if_exists: true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
