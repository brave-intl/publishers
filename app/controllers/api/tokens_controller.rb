class Api::TokensController < Api::BaseController

  include PublishersHelper

  def index
    max_age = params[:max_age] ? Integer(params[:max_age]).days : 6.weeks

    site_channel_details = SiteChannelDetails.recent_unverified_site_channels(max_age: max_age).order(:created_at)

    page_num = params[:page] || 1
    page_size = params[:per_page] || Rails.application.secrets[:default_api_page_size] || 100
    tokens = paginate site_channel_details, per_page: page_size, page: page_num

    render json: tokens, each_serializer: TokenSerializer
  rescue ArgumentError
    render(json: { message: "Invalid arguement" }, status: 400)
  end
end
