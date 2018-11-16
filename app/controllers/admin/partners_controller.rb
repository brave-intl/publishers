module Admin
  class PartnersController < AdminController
    include Search

    def index
      @partners = Partner

      if params[:q].present?
        # Returns an ActiveRecord::Relation of publishers for pagination
        search_query = "%#{remove_prefix_if_necessary(params[:q])}%"
        @partners = Partner.where(search_sql, *[search_query] * 7).distinct
      end

      @partners = @partners.suspended if params[:suspended].present?

      @partners = @partners.paginate(page: params[:page])
    end

    def new
      @partner = Partner.new
    end

    def create
      # Find any existing publishers so we don't create duplicate entries
      @partner = partner

      if @partner.persisted? && (@partner.partner? || @partner.admin?)
        flash.now[:alert] = "Email is already a partner"
        render "new"
      else
        # Ensure publisher gets the right role
        @partner.role = Publisher::PARTNER
        @partner.save
        MailerServices::PartnerLoginLinkEmailer.new(partner: @partner).perform
        redirect_to admin_publisher_path(@partner.id), flash: { notice: "Email sent" }
      end
    end

    private

    # Internal: Gets a partner
    #
    # Returns a Publisher if it exists otherwise returns a new Partner
    def partner
      existing_publisher =
        Publisher.by_pending_email_case_insensitive(email_params)
                 .or(Publisher.by_email_case_insensitive(email_params))
                 .first

      existing_publisher || Partner.new(email: email_params)
    end

    def email_params
      params.require(:email)
    end
  end
end
