class SiteBanner < ApplicationRecord
  include Rails.application.routes.url_helpers
  has_one_attached :logo
  has_one_attached :background_image
  belongs_to :publisher

  def read_only_react_property
    {
      title: self.title,
      description: self.description,
      backgroundUrl: url_for(SiteBanner.last.background_image),
      logoUrl: url_for(SiteBanner.last.logo)
    }.to_json
  end

  def url_for(object)
    return "" if object.nil?
    return "https://rewards-stg.s3.us-east-2.amazonaws.com/#{object.blob.key}"
    if Rails.env.development? || Rails.env.test?
      "https://127.0.0.1:3000" + rails_blob_path(object, disposition: "attachment", only_path: true)
    elsif Rails.env.production? || Rails.env.staging?
      # TODO Get the CDN
    end
  end
end
