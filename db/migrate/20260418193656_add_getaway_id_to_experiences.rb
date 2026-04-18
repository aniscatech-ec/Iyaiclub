class AddGetawayIdToExperiences < ActiveRecord::Migration[8.0]
  def change
    add_column :experiences, :getaway_id, :integer
    add_index :experiences, :getaway_id
  end
end
