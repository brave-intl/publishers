class Api::Public::ChannelsController < Api::BaseController
#  skip_before_action :verify_authenticity_token, only: [:identity]
#  force_ssl except: [:identity]

  def identity
    builder = JsonBuilders::IdentityJsonBuilder.new(publisher_name: params[:publisher]).build

    if builder.errors.present?
      render(status: 404,
        json: {
          errors: builder.errors.to_s
        })
    else
      render(status: 200, json: builder.result)
    end
  end
end
