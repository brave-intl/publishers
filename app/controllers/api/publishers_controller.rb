class Api::PublishersController < Api::BaseController

  def notify_unverified
    PublisherNotifierUnverified.new(
      publisher_id: params[:publisher_id],
      publisher_type: params[:publisher_type],
    ).perform
    render(json: { message: "success" })

    rescue PublisherNotifierUnverified::InvalidPublisherTypeError, PublisherNotifierUnverified::BlankParamsError => error
      render(json: { message: error.message }, status: 400)

    rescue PublisherNotifierUnverified::NoEmailsFoundError => error
      render(json: { message: error.message }, status: 500)
  end

end