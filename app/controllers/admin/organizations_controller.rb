module Admin
  class OrganizationsController < AdminController
    def index
      @organizations = Organization.paginate(page: params[:page])
    end

    def new
      @organization = Organization.new
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
      organization_permissions.upload_offline_billing = params[:billing] == "1"
      organization_permissions.upload_offline_invoice = params[:invoice] == "1"
      organization_permissions.upload_referral_codes = params[:referral] == "1"

      organization_permissions
    end

    def organization_params
      params.require(:organization).permit(:name)
    end
  end
end
