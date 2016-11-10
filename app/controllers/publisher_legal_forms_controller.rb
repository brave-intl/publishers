class PublisherLegalFormsController < ApplicationController
  before_action :authenticate_publisher!, except: %i(after_sign)
  before_action :require_verified_publisher, except: %i(after_sign)
  before_action :require_no_legal_form,
    only: %i(create new)
  before_action :require_legal_form,
    only: %i(after_sign show)

  layout "headless", only: %i(after_sign)

  def new
    @legal_form = current_publisher.build_legal_form
  end

  def create
    @legal_form = current_publisher.build_legal_form(legal_form_params)
    if @legal_form.save
      redirect_to(@legal_form)
    else
      render(:new)
    end
  end

  # Sign or view signed form. Embedded Docusign.
  def show
    return_url = after_sign_publisher_legal_forms_url(token: @legal_form.generate_after_sign_token)
    @signing_url = @legal_form.generate_signing_url(return_url: return_url)
  end

  # After the user signs the form at Docusign they're redirected here.
  # It's headless and should be loaded within the iframe from #create.
  # It refreshes the envelope status and saves to the LegalForm.
  # NOTE: This method does NOT require a publisher auth -- they may have
  # delegated the signing request (e.g. to accountant).
  def after_sign
    PublisherLegalFormSyncer.new(publisher_legal_form: @legal_form).perform
    # If the publisher is signed in, redirect to their dashboard.
    # Otherwise show a thank you message.
    # TODO: Websockets refresh the main page
    if @legal_form.completed? && current_publisher && current_publisher.bitcoin_address.present?
      render('publishers/finished')
    end
  rescue DocusignBaseService::TooManyRequestsError
    # TODO: Remove once webhooks are setup
    @docusign_rate_limited = true
  end

  private

  def legal_form_params
    params.require(:publisher_legal_form).permit(:form_type)
  end

  def require_legal_form
    if current_publisher && params[:id] && params[:id] == current_publisher.legal_form&.id
      @legal_form = current_publisher.legal_form
    elsif params[:token]
      @legal_form = PublisherLegalForm.find_using_after_sign_token(params[:token])
    end
    return if @legal_form
    redirect_to(home_publishers_path, alert: I18n.t("publisher_legal_forms.existing_required"))
  end

  def require_no_legal_form
    return if !current_publisher.legal_form
    redirect_to(current_publisher.legal_form)
  end

  def require_verified_publisher
    return if current_publisher.verified?
    redirect_to(root_path, alert: I18n.t("publishers.verification_required"))
  end
end
