# typed: ignore

module Admin
  class SecurityController < AdminController
    before_action :set_publisher

    def show
      @navigation_view = Views::Admin::NavigationView.new(@publisher).to_json
    end

    def totp_registration
      if @publisher.totp_registration
        PublisherNote.create(
          publisher: @publisher,
          created_by: current_user,
          note: "The creator #{@publisher.email}'s TOTP registration was deleted by #{current_user.email}"
        )

        @publisher.totp_registration.destroy
        flash[:notice] = "TOTP registration removed for #{@publisher.name}."
      else
        flash[:alert] = "No TOTP registration found for #{@publisher.name}."
      end
      redirect_to admin_security_path(@publisher)
    end

    private

    def set_publisher
      @publisher = Publisher.find(params[:id])
    end
  end
end
