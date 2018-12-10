module Admin
  class ChannelsController < AdminController
    include Search

    def index
      @channels = Channel

      if params[:q].present?
        query = params[:q].split(' ').map { |q| "%#{remove_prefix_if_necessary(q)}%" }.join(' ')
        @channels = @channels.search(query)
      end

      @channels = @channels.verified if params[:verified].present?

      @channels = @channels.order(created_at: :desc).paginate(page: params[:page])
    end
  end
end
