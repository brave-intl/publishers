class Admin::PublishersController < AdminController
  def index
    @publishers = Publisher.paginate(page: params[:page])
  end
end
