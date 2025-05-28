# typed: ignore

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
        query = params[:q].split(" ").map { |q| "%#{remove_prefix_if_necessary(q)}%" }.join(" ")
        @channels = @channels.search(query)
      end

      @channels = @channels.verified if params[:verified].present?

      begin
        # find the time of the last completed BannedAddressJob through sidekiq
        # This isn't something sidekiq is really meant to do, so the query is kind of
        # a mess.  If for some reason the query fails, we're going to display a message
        # that says the time couldn't be found.
        stats = Sidekiq::Metrics::Query.new.for_job(BannedAddressJob)
        utc_last_job_ran = stats.job_results.values[0].series["ms"].keys[0]
        @last_job_time = Time.strptime(utc_last_job_ran, "%H:%M")
      rescue
        @last_job_time = nil
      end

      case params[:type]
      when "website"
        @channels = @channels.site_channels
      when "youtube"
        @channels = @channels.youtube_channels
      when "twitch"
        @channels = @channels.twitch_channels
      end

      @channels = @channels.paginate(page: params[:page])
    end

    def destroy
      channel = Channel.find(params[:id])

      PublisherNote.create(
        publisher: channel.publisher,
        created_by: channel.publisher,
        note: "The channel #{channel.publication_title} at #{channel.details&.url} was deleted by #{current_user.email}"
      )

      @channel_id = channel.id
      DeletePublisherChannelJob.perform_now(@channel_id)
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

    def ofac_update
      # rather than trying to chain jobs, just perform the sorter ofac logic then kick off the address
      # comparison job
      new_ofac_list = ParseOfacListService.perform[:addresses]
      raise "Empty list" unless new_ofac_list.present?
      list = new_ofac_list.map { |addr| OfacAddress.new(address: addr) }
      ActiveRecord::Base.transaction do
        ActiveRecord::Base.connection.truncate_tables(:ofac_addresses)
        OfacAddress.import list
      end
      BannedAddressJob.perform_later
      redirect_to admin_channels_path, flash: {notice: "The OFAC list is being updated"}
    end

    private

    def sortable_columns
      [:created_at] + Channel::ADVANCED_SORTABLE_COLUMNS
    end
  end
end
