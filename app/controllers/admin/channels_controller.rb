module Admin
  class ChannelsController < AdminController
    include Search
    include ActiveRecord::Sanitization::ClassMethods

    def index
      @channels = if sort_column&.to_sym&.in? Channel::ADVANCED_SORTABLE_COLUMNS
        Channel.advanced_sort(sort_column.to_sym, sort_direction)
      else
        Channel.order(sanitize_sql_for_order("#{sort_column} #{sort_direction}"))
      end

      if params[:q].present?
        query = params[:q].split(' ').map { |q| "%#{remove_prefix_if_necessary(q)}%" }.join(' ')
        @channels = @channels.search(query)
      end

      @channels = @channels.verified if params[:verified].present?

      case params[:type]
      when 'website'
          @channels = @channels.site_channels
      when 'youtube'
          @channels = @channels.youtube_channels
      when 'twitch'
          @channels = @channels.twitch_channels
      end

      @channels = @channels.paginate(page: params[:page])
    end

    def duplicates
      @channels = Channel.duplicates

      respond_to do |format|
        format.html {}
        format.json {
          render json: @channels
        }
      end
    end

    private

    def sortable_columns
      [:created_at] + Channel::ADVANCED_SORTABLE_COLUMNS
    end
  end
end
