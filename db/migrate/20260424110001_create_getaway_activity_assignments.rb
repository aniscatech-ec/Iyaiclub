class CreateGetawayActivityAssignments < ActiveRecord::Migration[8.0]
  def change
    create_table :getaway_activity_assignments do |t|
      t.references :getaway,          null: false, foreign_key: true
      t.references :getaway_activity, null: false, foreign_key: true

      t.timestamps
    end

    add_index :getaway_activity_assignments,
              [:getaway_id, :getaway_activity_id],
              unique: true,
              name: "index_getaway_activity_assignments_unique"
  end
end
