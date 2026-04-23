class Advertisement < ApplicationRecord
  has_one_attached :image

  validates :title, presence: { message: "El título es obligatorio" }

  scope :active_ads, -> { where(active: true).order(:position, :created_at) }

  def tags_array
    return [] if tags.blank?
    tags.split(",").map(&:strip).reject(&:blank?)
  end
end
