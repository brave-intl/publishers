module Publishers
  class SettingsController < ApplicationController
    before_action :authenticate_publisher!

    def index
    end
  end
end
