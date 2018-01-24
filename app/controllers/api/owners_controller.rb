class Api::OwnersController < Api::BaseController
  include PublishersHelper
  include ActionController::Serialization

  def index
    render(json: Publisher.all)
  end
end