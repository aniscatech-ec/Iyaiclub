class BackfillReferralCodesForExistingUsers < ActiveRecord::Migration[8.0]
  def up
    User.where(referral_code: nil).find_each do |user|
      loop do
        code = SecureRandom.alphanumeric(8).upcase
        unless User.exists?(referral_code: code)
          user.update_column(:referral_code, code)
          break
        end
      end
    end
  end

  def down
    # No reversible — no borrar códigos ya asignados
  end
end
