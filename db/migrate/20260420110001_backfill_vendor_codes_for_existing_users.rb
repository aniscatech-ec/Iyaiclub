class BackfillVendorCodesForExistingUsers < ActiveRecord::Migration[8.0]
  def up
    User.where(vendor_code: nil).find_each do |user|
      loop do
        code = "VND-#{SecureRandom.alphanumeric(6).upcase}"
        unless User.exists?(vendor_code: code)
          user.update_column(:vendor_code, code)
          break
        end
      end
    end
  end

  def down
    # No-op: removing codes would break references
  end
end
