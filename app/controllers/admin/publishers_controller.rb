class Admin::PublishersController < AdminController
  before_action :get_publisher

  def index
    @publishers = Publisher

    if params[:q].present?
      # Returns an ActiveRecord::Relation of publishers for pagination
      @publishers = Publisher.where("publishers.id IN (#{sql(params[:q])})").distinct
    end

    if params[:suspended].present?
      @publishers = @publishers.suspended
    end

    @publishers = @publishers.paginate(page: params[:page])
  end

  def show
    @publisher = Publisher.find(params[:id])
    @note = PublisherNote.new
  end

  def edit
    @publisher = Publisher.find(params[:id])
  end

  def update
    @publisher.update(update_params)
    redirect_to admin_publisher_path(current_publisher)
  end

  # generates a publisher statement for an admin
  # does not send an email
  def generate_statement
    publisher = Publisher.find(params[:id])
    statement_period = params[:statement_period]
    statement = PublisherStatementGenerator.new(publisher: publisher,
                                                statement_period: statement_period.to_sym,
                                                created_by_admin: true).perform

    SyncPublisherStatementJob.perform_later(publisher_statement_id: statement.id, send_email: false)
    render(json: {
      id: statement.id,
      date: statement_period_date(statement.created_at),
      period: statement_period_description(statement.period.to_sym)
    }, status: 200)
  end

  def statement_ready
    statement = PublisherStatement.find(params[:id])
    if statement && statement.contents
      head 204
    else
      head 404
    end
  end

  def create_note
    publisher = Publisher.find(publisher_create_note_params[:publisher])
    admin = current_user
    note_content = publisher_create_note_params[:note]

    note = PublisherNote.new(publisher: publisher, created_by: admin, note: note_content)
    note.save!

    redirect_to(admin_publisher_path(publisher.id))
  end

  # Allows a restricted channel to be verified
  def approve_channel
    channel = Channel.find(admin_approval_channel_params)
    success = SiteChannelVerifier.new(has_admin_approval: true, channel: channel).perform
    if success
      Rails.logger.info("#{channel.publication_title} has been approved by admin #{current_user.name}, #{current_user.owner_identifier}")
      SlackMessenger.new(message: "#{channel.details.brave_publisher_id} has been approved by admin #{current_user.name}, #{current_user.owner_identifier}").perform
    end

    redirect_to(admin_publisher_path(channel.publisher))
  end

  private

  def get_publisher
    return unless params[:id].present? || params[:publisher_id].present?
    @publisher = Publisher.find(params[:id] || params[:publisher_id])
  end

  def publisher_create_note_params
    params.require(:publisher_note).permit(:publisher, :note)
  end

  def admin_approval_channel_params
    params.require(:channel_id)
  end

  def update_params
    params.require(:publisher).permit(
      :excluded_from_payout
    )
  end

  private

  def remove_prefix_if_necessary(query)
    query = query.sub("publishers#uuid:", "")
    query = query.sub("youtube#channel:", "")
    query = query.sub("twitch#channel:", "")
    query = query.sub("twitch#author:", "")
    query = query.sub("twitter#channel:", "")
  end

  # Returns an array of publisher ids that match the query
  def sql(query)
    query = remove_prefix_if_necessary(query)
    %{SELECT publishers.id
      FROM   publishers
             INNER JOIN(SELECT channels.*
                        FROM   channels
                               INNER JOIN site_channel_details
                                       ON site_channel_details.id = channels.details_id
                                          AND channels.details_type = 'SiteChannelDetails'
                                          AND site_channel_details.brave_publisher_id ILIKE '%#{query}%'
                        UNION ALL
                        SELECT channels.*
                        FROM   channels
                               INNER JOIN youtube_channel_details
                                       ON youtube_channel_details.id =
                                          channels.details_id
                                          AND youtube_channel_details.title ILIKE '%#{query}%'
                                          OR youtube_channel_details.youtube_channel_id ILIKE '%#{query}%'
                        UNION ALL
                        SELECT channels.*
                        FROM   channels
                               INNER JOIN twitch_channel_details
                                       ON twitch_channel_details.id = channels.details_id
                                          AND twitch_channel_details.NAME ILIKE '%#{query}%')
                                         c
                     ON c.publisher_id = publishers.id
      UNION ALL
      SELECT publishers.id
      FROM publishers
      WHERE publishers.email ILIKE '%#{query}%'
            OR publishers.name ILIKE '%#{query}%'
            OR publishers.id::text = '#{query}'}
  end
end
