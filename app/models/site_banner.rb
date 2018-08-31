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
      logoUrl: url_for(SiteBanner.last.logo),
      donationAmounts: self.donation_amounts
    }
  end

  def url_for(object)
    return nil if object.nil? || object.attachment.nil?

    extension = if object.blob.content_type == "image/png"
                  ".png"
                elsif object.blob.content_type.in?(['image/jpg', 'image/jpeg'])
                  ".jpeg"
                end

    if Rails.env.development? || Rails.env.test?
      "https://0.0.0.0:3000" + rails_blob_path(object, only_path: true) + extension
    elsif Rails.env.staging?
      return "https://rewards-stg.s3.us-east-2.amazonaws.com/#{object.blob.key}"
    elsif Rails.env.production?
      # TODO
    end
  end
end
