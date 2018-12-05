class Api::V1::Public::PublishersController < Api::V1::Public::BaseController
  def totals
    render(
      json: {
        verified_with_channel: Publisher.where(role: Publisher::PUBLISHER).email_verified.joins(:channels).distinct(:id).count
      },
      status: 200
    )
  end
end
