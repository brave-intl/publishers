class AdminController < ApplicationController
  before_action :protect
  
  include PublishersHelper

  # Override this value to specify the number of elements to display at a time
  # on index pages. Defaults to 20.
  def records_per_page
    20
  end

  def show
    @publisher = Publisher.find(params[:id])
    @note = PublisherNote.new
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
    success = SiteChannelVerifier.new(admin_approval: true, channel: channel).perform
    if success
      Rails.logger.info("#{channel.publication_title} has been approved by admin #{current_user.name}, #{current_user.owner_identifier}")
      SlackMessenger.new(message: "#{channel.details.brave_publisher_id} has been approved by admin #{current_user.name}, #{current_user.owner_identifier}").perform
    end

    redirect_to(admin_publisher_path(channel.publisher))
  end

  private

  def protect
    authorize! :access, :admin
  end

  def publisher_create_note_params
    params.require(:publisher_note).permit(:publisher, :note)
  end

  def admin_approval_channel_params
    params.require(:channel_id)
  end
end
