class PublishersController < ApplicationController
  include PublishersHelper

  before_action :authenticate_via_token,
    only: %i(show)
  before_action :authenticate_publisher!,
    only: %i(download_verification_file
             edit_payment_info
             home
             log_out
             update_payment_info
             verification
             verify)
  before_action :require_unauthenticated_publisher,
    only: %i(create
             new)
  before_action :require_unverified_publisher,
    only: %i(verification
             verify)
  before_action :require_verified_publisher,
    only: %i(edit_payment_info
             home
             update_payment_info)

  def new
    @publisher = Publisher.new
  end

  def create
    @publisher = Publisher.new(publisher_create_params)
    if @publisher.save
      # TODO: Change to #deliver_later ?
      PublisherMailer.welcome(@publisher).deliver_now!
      PublisherMailer.verification_instructions(@publisher).deliver_now
      sign_in(:publisher, @publisher)
      redirect_to(publisher_next_step_path(current_publisher))
    else
      render(:new, alert: "some errors with the submission")
    end
  end

  # Domain verification. Show verification options.
  def verification
  end

  # Call to Eyeshade to perform verification
  # TODO: Rate limit
  # TODO: Support XHR
  def verify
    PublisherVerifier.new(publisher: current_publisher).perform
    if current_publisher.verified?
      flash.notice = I18n.t("publishers.verify_success")
      redirect_to(publisher_next_step_path(current_publisher))
    else
      flash.now[:notice] = I18n.t("publishers.verify_failure")
      render(:verification)
    end
  end

  def download_verification_file
    generator = PublisherVerificationFileGenerator.new(publisher: current_publisher)
    content = generator.generate_file_content
    send_data(content, filename: generator.filename)
  end

  # Entrypoint for the authenticated re-login link.
  def show
    redirect_to(home_publishers_path)
  end

  # Domain verified. See balance and submit payment info.
  def home
  end

  def edit_payment_info
    @publisher = current_publisher
  end

  def update_payment_info
    @publisher = current_publisher
    @publisher.assign_attributes(publisher_payment_info_params)
    if @publisher.save
      # TODO: Redirect to next step
      redirect_to(home_publishers_path)
    else
      # TODO: Oops message
      render(:edit_payment_info)
    end
  end

  def log_out
    path = after_sign_out_path_for(current_publisher)
    sign_out(current_publisher)
    redirect_to(path, notice: I18n.t("publishers.logged_out"))
  end

  private

  def authenticate_via_token
    return if current_publisher || params[:id].blank? || params[:token].blank?
    publisher = Publisher.find(params[:id])
    if publisher.authentication_token.present? && publisher.authentication_token == params[:token]
      sign_in(:publisher, publisher)
    end
  end

  def publisher_create_params
    params.require(:publisher).permit(:email, :brave_publisher_id, :name, :phone)
  end

  def publisher_payment_info_params
    params.require(:publisher).permit(:bitcoin_address)
  end

  # If an active session is present require users to explicitly sign out
  def require_unauthenticated_publisher
    return if !current_publisher
    redirect_to(publisher_next_step_path(current_publisher), alert: I18n.t("publishers.already_logged_in"))
  end

  def require_unverified_publisher
    return if !current_publisher.verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: I18n.t("publishers.verification_already_done"))
  end

  def require_verified_publisher
    return if current_publisher.verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: I18n.t("publishers.verification_required"))
  end
end
