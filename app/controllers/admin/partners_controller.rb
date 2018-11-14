class Admin::PartnersController < AdminController
  def new
    @partner = Partner.new
  end

  def create
    @partner = Partner.new(partner_params)


    if @partner.valid?
      # send the email
      # tell the user they sent the email
      MailerServices::PartnerLoginLinkEmailer.new(partner: @partner).perform
      redirect_to admin_publisher_path(@partner.id), flash: { notice: 'Email sent' }
    else
      render 'new'
    end
    # it's invalid when the email is blank or already taken by a partner


    # they check to see if the email already exists
    # if email already exists
    #   send the email
    #   and tell the user they sent the email
    # end

    # if email doesn't exist
    #  check for unverified publishers
    #  send the email
    # else
    #   tell user it failed
    # end
  end

  def partner_params
    params.require(:partner).permit(:email)
  end
end
