class Api::Nextv1::RegistrationsController < Api::Nextv1::BaseController
  include PublishersHelper

  skip_before_action :authenticate_publisher!

  # Number of requests to #create before we present a captcha.
  THROTTLE_THRESHOLD_REGISTRATION = 3

  before_action :require_unauthenticated_publisher

  # Used by sign_up.html.slim.  If a user attempts to sign up with an existing email, a log in email
  # is sent to the existing user. Otherwise, a new publisher is created and a sign up email is sent.
  def create
    # First check if publisher with the email already exists.
    existing_publisher = Publisher.by_email_case_insensitive(params[:email]).first
    email_existing_publisher(existing_publisher) and return if existing_publisher

    # Check if an existing email unverified publisher record exists to prevent duplicating unverified publishers.
    # Requiring `email: nil` ensures we do not select a publisher with the same pending_email
    # as a publisher in the middle of the change email flow
    @publisher = Publisher.find_or_create_by(pending_email: params[:email], email: nil, role: Publisher::PUBLISHER)
    @publisher_email = @publisher.pending_email
    @publisher.agreed_to_tos = Time.now if params[:terms_of_service].present?

    if params[:terms_of_service] && @publisher.save
      MailerServices::VerifyEmailEmailer.new(publisher: @publisher, locale: locale_from_header).perform
      render json: {}, status: 200
    else
      Rails.logger.error("Create publisher errors: #{@publisher.errors.full_messages}")
      render json: {}, status: 400
    end
  end

  # This is the method that is called after the user clicks the "Log In" button
  # If the user is an existing publisher we will send them a log in link, if they are not
  # then we provide the ability to create an account by clicking the alert on the page.
  def update
    @publisher = Publisher.by_email_case_insensitive(params[:email]).first
    @publisher_email = params[:email]

    MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform

    # If the publisher doesn't exist we'll just pretend like they do
    render json: {}, status: 200
  end

  def tos_links
    render json: {tos: ENV["TOS_LINK"], help: ENV["SUPPORT_LINK"]}, status: 200
  end

  private

  def email_existing_publisher(publisher)
    @publisher = publisher
    @publisher_email = publisher.email
    MailerServices::PublisherLoginLinkEmailer.new(publisher: @publisher).perform
    render json: {}, status: 200
  end

  def locale_from_header
    (request.env["HTTP_ACCEPT_LANGUAGE"].scan(/^[a-z]{2}/).first == "ja") ? :ja : :en
  rescue
    I18n.default_locale
  end

  # If an active session is present require users to explicitly sign out
  def require_unauthenticated_publisher
    return unless current_publisher

    redirect_to(publisher_next_step_path(current_publisher))
  end
end
