class Api::Nextv1::PublishersController < Api::Nextv1::BaseController
  def me
    render(json: current_publisher.to_json, status: 200)
  end

  def update
    # If user enters current email address delete the pending email attribute
    update_params[:pending_email] = update_params[:pending_email]&.downcase
    update_params[:pending_email] = nil if update_params[:pending_email] == current_publisher.email

    success = current_publisher.update(update_params)

    if success && update_params[:pending_email]
      MailerServices::ConfirmEmailChangeEmailer.new(publisher: current_publisher).perform
    end

    return success

    respond_to do |format|
      if success
        format.json { render json: {} }
      else
        format.json { render(json: {errors: current_publisher.errors}, status: 400) }
      end
    end
  end

  def update_params
    params.require(:publisher).permit(:email, :name, :subscribed_to_marketing_emails, :thirty_day_login)
  end
end
