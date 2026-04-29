class AddReferralCodeToSubscriptionsAndTickets < ActiveRecord::Migration[8.0]
  def change
    add_column :subscriptions, :referral_code, :string, limit: 12
    add_column :tickets,       :referral_code, :string, limit: 12
  end
end
