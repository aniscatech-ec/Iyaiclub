class CreateGetawayActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :getaway_activities do |t|
      t.string  :name,  null: false
      t.string  :icon              # clase FontAwesome, ej: "fa-hiking"
      t.integer :position, default: 0

      t.timestamps
    end
  end
end
