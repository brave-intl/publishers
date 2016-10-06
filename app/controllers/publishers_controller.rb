class PublishersController < ApplicationController
  include PublishersHelper

  before_action :authenticate_publisher!,
    only: %i(download_verification_file home log_out payment_info update_payment_info verification)
  before_action :require_unauthenticated_publisher,
    only: %i(new create)
  before_action :require_verified_publisher,
    only: %i(home payment_info update_payment_info)

  def new
    @publisher = Publisher.new
  end

  def create
    @publisher = Publisher.new(publisher_create_params)
    if @publisher.save
      sign_in(:publisher, @publisher)
      redirect_to(publisher_next_step_path(current_publisher))
    else
      render(:new, alert: "some errors with the submission")
    end
  end

  # Domain verification. Show verification options.
  def verification
  end

  def download_verification_file
    generator = PublisherVerificationFileGenerator.new(current_publisher)
    content = generator.generate_file_content
    send_data(content, filename: generator.filename)
  end

  # Domain verified. See balance and submit payment info.
  def home
  end

  # Submit payment info (wallet address and tax info)
  def payment_info
    @publisher = current_publisher
  end

  def update_payment_info
    @publisher = current_publisher
    @publisher.assign_attributes(publisher_payment_update_params)
    if @publisher.save
      redirect_to current_publishers_path
    else
      render(:payment_info, alert: "some errors with the submission")
    end
  end

  def log_out
    path = after_sign_out_path_for(current_publisher)
    sign_out(current_publisher)
    redirect_to(path, notice: I18n.t("publishers.logged_out"))
  end

  private

  def publisher_create_params
    params.require(:publisher).permit(:email, :base_domain, :name, :phone)
  end

  def publisher_payment_update_params
    params.require(:publisher).permit(:bitcoin_address)
  end

  # If an active session is present require users to explicitly sign out
  def require_unauthenticated_publisher
    return if !current_publisher
    redirect_to(publisher_next_step_path(current_publisher), alert: I18n.t("publishers.already_logged_in"))
  end

  def require_verified_publisher
    return if current_publisher.verified?
    redirect_to(publisher_next_step_path(current_publisher), alert: I18n.t("publishers.verification_required"))
  end
end
