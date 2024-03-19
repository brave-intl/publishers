class Api::Nextv1::PublishersController < Api::Nextv1::BaseController
  include PublishersHelper
  include PendingActions
  include ActionController::MimeResponds

  def me
    publisher_hash = JSON.parse(current_publisher.to_json)
    response_data = {
      **publisher_hash,
      two_factor_enabled: two_factor_enabled?(current_publisher)
    }
    render(json: response_data.to_json, status: 200)
  end

  def secdata
    response_data = {
      u2f_enabled: u2f_enabled?(current_publisher),
      totp_enabled: totp_enabled?(current_publisher),
      u2f_registrations: current_publisher.u2f_registrations
    }

    render(json: response_data.to_json, status: 200)
  end

  def update
    # If user enters current email address delete the pending email attribute
    update_params[:pending_email] = update_params[:pending_email]&.downcase
    update_params[:pending_email] = nil if update_params[:pending_email] == current_publisher.email

    success = current_publisher.update(update_params)

    if success && update_params[:pending_email]
      MailerServices::ConfirmEmailChangeEmailer.new(publisher: current_publisher).perform
    end

    respond_to do |format|
      if success
        format.json { render json: {} }
      else
        format.json { render(json: {errors: current_publisher.errors}, status: 400) }
      end
    end
  end

  class DestroyPublisher < StepUpAction
    call do |publisher_id|
      current_publisher = Publisher.find(publisher_id)
      PublisherRemovalJob.perform_later(publisher_id)
      sign_out(current_publisher)
      respond_to do |format|
        format.json { render json: {} }
      end
    end
  end

  def destroy
    DestroyPublisher.new(current_publisher.id).step_up! self
  end

  def update_params
    params.require(:publisher).permit(:email, :name, :subscribed_to_marketing_emails, :thirty_day_login)
  end
end
