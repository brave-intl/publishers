class Admin::PublishersController < AdminController
  before_action :get_publisher
  include Search
  include ActiveRecord::Sanitization::ClassMethods

  def index
    ActiveRecord::Base.connected_to(role: :reading) do
      @publishers = if sort_column&.to_sym&.in? Publisher::ADVANCED_SORTABLE_COLUMNS
                      Publisher.advanced_sort(sort_column.to_sym, sort_direction)
                    else
                      Publisher.order(sanitize_sql_for_order("#{sort_column} #{sort_direction} NULLS LAST"))
                    end

      if params[:q].present?

        @publishers = publishers_search(@publishers, params[:q])
      end

      if params[:status].present? && PublisherStatusUpdate::ALL_STATUSES.include?(params[:status])
        # Effectively sanitizes the users input
        method = PublisherStatusUpdate::ALL_STATUSES.detect { |x| x == params[:status] }
        @publishers = @publishers.send(method)
      end

      if params[:role].present?
        @publishers = @publishers.where(role: params[:role])
      end

      if params[:uphold_status].present?
        @publishers = @publishers.joins(:uphold_connection).where('uphold_connections.status = ?', params[:uphold_status])
      end

      if params[:feature_flag].present?
        found_flag = UserFeatureFlags::VALID_FEATURE_FLAGS.find { |flag| flag == params[:feature_flag].to_sym }

        @publishers = @publishers.send(found_flag)
      end

      if params[:two_factor_authentication_removal].present?
        @publishers = @publishers.joins(:two_factor_authentication_removal).distinct
      end

      @publishers = @publishers.where.not(email: nil).or(@publishers.where.not(pending_email: nil)) # Don't include deleted users

      respond_to do |format|
        format.json { render json: @publishers.to_json(only: [:id, :name, :email], methods: :avatar_color) }
        format.html { @publishers = @publishers.group(:id).paginate(page: params[:page], total_entries: total_publishers) }
      end
    end
  end

  def show
    @publisher = Publisher.find(params[:id])
    @navigation_view = Views::Admin::NavigationView.new(@publisher).as_json.merge({ navbarSelection: "Dashboard" }).to_json
    @current_user = current_user

    if payout_in_progress? || Date.today.day < 12 # Let's display the payout for 5 days after it should complete (on the 8th)
      @payout_report = PayoutReport.where(final: true, manual: false).order(created_at: :desc).first
      @payout_message = PayoutMessage.find_by(payout_report: @payout_report, publisher: @publisher)
    end
  end

  def wallet_info
    @publisher = Publisher.find(params[:publisher_id])
    @potential_referral_payment = @publisher.most_recent_potential_referral_payment
    @referral_owner_status = PromoClient.owner_state.find(id: @publisher.id)
    render partial: "wallet_info"
  end

  def edit
    @publisher = Publisher.find(params[:id])
    @navigation_view = Views::Admin::NavigationView.new(@publisher).as_json.merge({ navbarSelection: "Dashboard" }).to_json
  end

  def update
    @publisher.update(update_params)
    @publisher.update_feature_flags_from_form(update_feature_flag_params)

    redirect_to admin_publisher_path(@publisher), flash: { notice: "Saved successfully" }
  end

  def destroy
    PublisherRemovalJob.perform_later(publisher_id: @publisher.id)
    flash[:alert] = "Deletion job enqueued. This usually takes a few seconds to complete"
    redirect_to admin_publisher_path(@publisher)
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

  def cancel_two_factor_authentication_removal
    publisher = Publisher.find(params[:id])
    publisher.two_factor_authentication_removal.destroy
    redirect_to(admin_publisher_path(publisher), flash: { alert: "2fa removal was cancelled" })
  end

  def refresh_uphold
    connection = UpholdConnection.find_by(publisher: params[:publisher_id])
    if connection.present?
      connection.sync_connection!
      connection.create_uphold_cards
    end
    redirect_to admin_publisher_path(@publisher.id)
  end

  def sign_in_as_user
    if @publisher.admin?
      render status: 401, json: {
        error: "You cannot sign in as another admin",
      }
    end

    authentication_token = PublisherTokenGenerator.new(publisher: @publisher).perform

    login_url = request.base_url + "/publishers/" + @publisher.id + "?token=" + authentication_token
    render json: {
      login_url: login_url,
    }
  end

  private

  # Internal: Caches and returns the value for total number of publishers
  #
  # Returns the number of entries in the Publishers table
  def total_publishers
    Rails.cache.fetch('total_publishers', expires_in: 12.hours) do
      Publisher.all.count
    end
  end

  def get_publisher
    return unless params[:id].present? || params[:publisher_id].present?
    @publisher = Publisher.find(params[:publisher_id] || params[:id])
  end

  def admin_approval_channel_params
    params.require(:channel_id)
  end

  def update_params
    params.require(:publisher).permit(
      :excluded_from_payout
    )
  end

  def update_feature_flag_params
    params.require(:publisher).permit(
      UserFeatureFlags::VALID_FEATURE_FLAGS
    )
  end

  def sortable_columns
    [:last_sign_in_at, :created_at, Publisher::VERIFIED_CHANNEL_COUNT]
  end
end
