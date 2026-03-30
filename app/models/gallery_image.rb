class GalleryImage < ApplicationRecord
  belongs_to :gallery

  # Cada registro es una sola imagen
  has_one_attached :file

  def display_image
    file.variant(resize_to_limit: [400, 225], saver: { quality: 80 })
  end
end
