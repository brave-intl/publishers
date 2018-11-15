class Admin::PartnersController < AdminController
  def new
    @partner = Partner.new
  end

  def create
    # Find any existing publishers so we don't create duplicate entries
    existing_publisher = Publisher.by_pending_email_case_insensitive(email_param)
      .or(Publisher.by_email_case_insensitive(email_param))
      .first

    @partner = existing_publisher || Partner.new(email: email_param)

    if @partner.persisted? && (@partner.partner? || @partner.admin?)
      flash.now[:alert] = 'Email is already a partner'
      render 'new'
    else
      # Ensure publisher gets the right role
      @partner.role = Publisher::PARTNER
      @partner.save
      MailerServices::PartnerLoginLinkEmailer.new(partner: @partner).perform
      redirect_to admin_publisher_path(@partner.id), flash: { notice: 'Email sent' }
    end
  end

  def email_param
    params.require(:email)
  end
end
