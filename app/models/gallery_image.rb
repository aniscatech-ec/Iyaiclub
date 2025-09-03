class GalleryImage < ApplicationRecord
  belongs_to :gallery

  # Cada registro es una sola imagen
  has_one_attached :file
end
