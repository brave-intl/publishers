class Admin::PublishersController < AdminController
  def index
    @publishers = Publisher
    if params[:q].present?
      @publishers = @publishers.where("email ILIKE :email OR name ILIKE :name",
                      {
                        email: "%#{params[:q]}%",
                        name: "%#{params[:q]}%"
                      }
                    )
    end

    @publishers = @publishers.paginate(page: params[:page])
  end
end
