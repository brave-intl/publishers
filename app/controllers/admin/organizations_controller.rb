module Admin
  class OrganizationsController < AdminController
    def index
      @organizations = Organization.paginate(page: params[:page])
    end

    def new
      @organization = Organization.new
      @organization.permissions = OrganizationPermission.new
    end

    def create
      @organization = Organization.new(organization_params)
      @organization.permissions = permissions(OrganizationPermission.new)

      if @organization.save
        redirect_to admin_organization_path(@organization.id)
      else
        render :new
      end
    end

    def show
      @organization = Organization.find(params[:id])
    end

    def edit
      @organization = Organization.find(params[:id])
    end

    def update
      @organization = Organization.find(params[:id])
      @organization.permissions = permissions(@organization.permissions)

      if @organization.update(organization_params)
        redirect_to admin_organization_path(@organization.id)
      else
        render :edit
      end
    end

    def permissions(organization_permissions)
      organization_permissions.uphold_wallet = params[:uphold].present?
      organization_permissions.referral_codes = params[:referral_codes].present?
      organization_permissions.offline_reporting = params[:offline_reporting].present?

      organization_permissions
    end

    def organization_params
      params.require(:organization).permit(:name)
    end
  end
end
