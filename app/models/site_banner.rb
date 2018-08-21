class SiteBanner < ApplicationRecord
  has_one_attached :logo
  has_one_attached :background_image
  belongs_to :publisher

  def read_only_react_property
    {
      title: self.title,
      description: self.description
    }.to_json
  end
end
