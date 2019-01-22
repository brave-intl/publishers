class Publishers::ReferralCodesController < ApplicationController
  include PromosHelper
  before_action :authenticate_publisher!

  def index
    render json: {"hi": "test"}
  end

end
