class Api::PublishersController < Api::BaseController
  def index_by_brave_publisher_id
    publishers = Publisher.where(
      brave_publisher_id: params[:brave_publisher_id]
    )
    render(json: publishers)
  end
end
