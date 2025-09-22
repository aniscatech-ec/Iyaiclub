class GalleryImage < ApplicationRecord
  belongs_to :gallery

  # Cada registro es una sola imagen
  has_one_attached :file

  def display_image
    # Resize y crop para 400x225 (16:9)
    file.variant(resize_to_limit: [400, 225])

  end
end
