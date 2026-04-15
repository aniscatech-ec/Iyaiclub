class Gallery < ApplicationRecord
  belongs_to :establishment

  # Una galería puede tener muchas imágenes
  has_many :gallery_images, dependent: :destroy
  accepts_nested_attributes_for :gallery_images, allow_destroy: true,
                                                 reject_if: ->(attrs) { attrs["file"].blank? && attrs["id"].blank? }

end
