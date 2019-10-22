module Publishers
  class SettingsController < ApplicationController
    before_action :authenticate_publisher!

    def index
      @publisher = current_publisher
    end
  end
end
