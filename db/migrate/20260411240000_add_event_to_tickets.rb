class AddEventToTickets < ActiveRecord::Migration[8.0]
  def change
    add_reference :tickets, :event, null: true, foreign_key: true
  end
end
