class Admin::PublishersController < AdminController
  before_action :get_publisher
  include Search
  include ActiveRecord::Sanitization::ClassMethods

  def index
    @publishers = if sort_column&.to_sym&.in? Publisher::ADVANCED_SORTABLE_COLUMNS
                    Publisher.advanced_sort(sort_column.to_sym, sort_direction)
                  else
                    Publisher.order(sanitize_sql_for_order("#{sort_column} #{sort_direction} NULLS LAST"))
                  end

    if params[:q].present?
      # Returns an ActiveRecord::Relation of publishers for pagination
      search_query = remove_prefix_if_necessary(params[:q])
      search_query = "%#{search_query}%" unless is_a_uuid?(search_query)

      @publishers = @publishers.where(search_sql, search_query: search_query)
    end

    @publishers = @publishers.suspended if params[:suspended].present?
    @publishers = @publishers.group(:id).paginate(page: params[:page])
  end

  def show
    @publisher = Publisher.find(params[:id])
    @potential_referral_payment = PayoutReport.most_recent_final_report&.potential_payments&.where(publisher_id: @publisher.id, channel_id: nil)&.first
    @note = PublisherNote.new
  end

  def edit
    @publisher = Publisher.find(params[:id])
  end

  def update
    @publisher.update(update_params)

    redirect_to admin_publisher_path(@publisher)
  end

  def statement
    statement_period = params[:statement_period]
    @transactions = PublisherStatementGetter.new(publisher: @publisher, statement_period: statement_period).perform
    @statement_period = publisher_statement_period(@transactions)
    statement_file_name = publishers_statement_file_name(@statement_period)

    statement_string = render_to_string layout: "statement", template: "publishers/statement"
    send_data statement_string, filename: statement_file_name, type: "application/html"
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
    @publisher = Publisher.find(params[:publisher_id] || params[:id])
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

  def sortable_columns
    [:last_sign_in_at, :created_at, Publisher::VERIFIED_CHANNEL_COUNT]
  end

  def is_a_uuid?(uuid)
    # https://stackoverflow.com/questions/47508829/validate-uuid-string-in-ruby-rails
    uuid_regex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/
    uuid_regex.match?(uuid.to_s.downcase)
  end
end
