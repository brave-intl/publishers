class Api::V2::Public::BaseController < ActionController::API
    # This BaseController does not IP whitelist, whereas API::BaseController does
    before_action :set_public_cache_control
  
    def set_public_cache_control
      expires_in 1.hour, public: true
    end
  end