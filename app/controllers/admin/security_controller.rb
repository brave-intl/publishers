module Admin
  class SecurityController < AdminController
    def show
      @publisher = Publisher.find(params[:id])
    end
  end
end
