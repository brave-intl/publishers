class Api::Nextv1::PublishersController < Api::Nextv1::BaseController
  def me
    render(json: current_publisher.to_json, status: 200)
  end
end
