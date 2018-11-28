module Admin
  class PartnersController < AdminController
    include Search

    def index
      @partners = Partner

      if params[:q].present?
        # Returns an ActiveRecord::Relation of publishers for pagination
        search_query = "%#{remove_prefix_if_necessary(params[:q])}%"
        @partners = Partner.where(search_sql, search_query: search_query).distinct
      end

      @partners = @partners.suspended if params[:suspended].present?
      @partners = @partners.where(created_by: current_user) if params[:created_by_me].present?

      @partners = @partners.order(created_at: :desc).paginate(page: params[:page])
    end

    def new
      @partner = Partner.new
    end

    def create
      # Find any existing publishers so we don't create duplicate entries
      @partner = partner
      @organization = organization

      if @partner.persisted? && (@partner.partner? || @partner.admin?)
        flash.now[:alert] = "Email is already a partner"
        render :new
      elsif @organization.persisted?
        flash.now[:alert] = "The organization '#{params[:organization_name]}' already exists. Please have a partner of the organization add the user you want or ask Engineering team for assistance"
        render :new
      else
        # Ensure publisher gets the right role
        @partner.role = Publisher::PARTNER
        @partner.created_by = current_user
        @partner.save
        @organization.save
        Membership.create(member: @partner, organization: @organization)
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

    def organization
      Organization.find_by(name: params[:organization_name]) || Organization.new(name: params[:organization_name])
    end

    def email_params
      params.require(:email)
    end

    def organization_name
      params.require(:organization_name)
    end
  end
end
