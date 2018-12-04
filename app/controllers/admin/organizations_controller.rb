module Admin
  class OrganizationsController < AdminController
    def index
      @organizations = Organization.paginate(page: params[:page])
    end

    def show
      @organization = Organization.find_by(id: params[:id])
    end
  end
end
