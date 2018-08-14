class BannersController < ApplicationController
  def new
    @publisher_id = current_publisher.id
  end
end
