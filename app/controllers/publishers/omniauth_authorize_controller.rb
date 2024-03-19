module Publishers
  class OmniauthAuthorizeController < Devise::OmniAuthauthorizeController
    def redirect_options
      { allow_other_host: true }
    end
  end
end