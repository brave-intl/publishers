module Admin
  class ReservedPublicNamesController < AdminController
    before_action :set_reserved_public_name, only: [:update, :destroy]

    def index
      @reserved_public_names = ReservedPublicName.order(created_at: :desc)
                                                .where("public_name ILIKE ?", "%#{params[:search]}%")
                                                .paginate(page: params[:page])
      @new_reserved_public_name = ReservedPublicName.new
    end

    def create
      @reserved_public_name = ReservedPublicName.new(reserved_public_name_params)

      if @reserved_public_name.save
        redirect_to admin_reserved_public_names_path, notice: "Reserved public name added successfully."
      else
        redirect_to admin_reserved_public_names_path, alert: "Failed to add reserved public name."
      end
    end

    def update
      if @reserved_public_name.update(reserved_public_name_params)
        redirect_to admin_reserved_public_names_path, notice: "Updated successfully."
      else
        redirect_to admin_reserved_public_names_path, alert: "Update failed."
      end
    end

    def destroy
      @reserved_public_name.destroy
      redirect_to admin_reserved_public_names_path, notice: "Deleted successfully."
    end

    private

    def set_reserved_public_name
      @reserved_public_name = ReservedPublicName.find(params[:id])
    end

    def reserved_public_name_params
      params.require(:reserved_public_name).permit(:public_name, :permanent)
    end
  end
end
