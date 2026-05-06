class Review < ApplicationRecord
  belongs_to :establishment
  belongs_to :user

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :comment, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :establishment_id, message: "ya dejaste una reseña en este establecimiento" }
end
