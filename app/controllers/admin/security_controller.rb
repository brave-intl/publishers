module Admin
  class SecurityController < AdminController
    def show
      @publisher = Publisher.find(params[:id])
      @navigation_view = Views::Admin::NavigationView.new(@publisher).to_json
    end
  end
end
