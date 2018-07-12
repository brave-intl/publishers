class Api::V1::Public::BaseController < ActionController::API
  # This BaseController does not IP whitelist, whereas API::BaseController does
end