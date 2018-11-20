module Admin
  class ChannelsController < AdminController
    def index
      @channels = Channel

      if params[:q].present?
        query = "%#{remove_prefix_if_necessary(params[:q])}%"
        @channels = @channels.search(query)
      end

      @channels = @channels.verified if params[:verified].present?

      @channels = @channels.order(created_at: :desc).paginate(page: params[:page])
    end

    private

    # TODO: Remove when https://github.com/brave-intl/publishers/pull/1354 is merged
    def remove_prefix_if_necessary(query)
      query = query.sub("publishers#uuid:", "")
      query = query.sub("youtube#channel:", "")
      query = query.sub("twitch#channel:", "")
      query = query.sub("twitch#author:", "")
      query = query.sub("twitter#channel:", "")
      query.strip
    end
  end
end
