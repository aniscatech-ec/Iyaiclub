class AddFreeEntryToGetaways < ActiveRecord::Migration[8.0]
  def change
    add_column :getaways, :free_entry, :boolean, default: false, null: false
  end
end
