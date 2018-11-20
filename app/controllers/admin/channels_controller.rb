module Admin
  class ChannelsController < AdminController
    include Search

    def index
      @channels = Channel

      if params[:q].present?
        # Returns an ActiveRecord::Relation of publishers for pagination
        search_query = "%#{remove_prefix_if_necessary(params[:q])}%"
        @channels = @channels
                      .joins(:publisher)
                      .left_outer_joins(:site_channel_details)
                      .left_outer_joins(:youtube_channel_details)
                      .left_outer_joins(:twitch_channel_details)

        @channels =
          @channels.where('publishers.email LIKE ?', search_query)
          .or(@channels.where('publishers.name LIKE ?', search_query))
          .or(@channels.where('site_channel_details.brave_publisher_id LIKE ?', search_query))
          .or(@channels.where('twitch_channel_details.twitch_channel_id LIKE ?', search_query))
          .or(@channels.where('twitch_channel_details.display_name LIKE ?', search_query))
          .or(@channels.where('twitch_channel_details.email LIKE ?', search_query))
          .or(@channels.where('youtube_channel_details.youtube_channel_id LIKE ?', search_query))
          .or(@channels.where('youtube_channel_details.auth_email LIKE ?', search_query))
      end

      @channels = @channels.verified if params[:verified].present?

      @channels = @channels.order(created_at: :desc).paginate(page: params[:page])
    end
  end
end
