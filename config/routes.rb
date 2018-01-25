Rails.application.routes.draw do
  resources :publishers, only: %i(create update new show) do
    collection do
      get :sign_up
      get :create_done
      post :resend_email_verify_email, action: :resend_email_verify_email
      get :home
      get :log_in, action: :new_auth_token, as: :new_auth_token
      post :log_in, action: :create_auth_token, as: :create_auth_token
      get :expired_auth_token
      get :log_out
      get :email_verified
      get :status
      get :balance
      get :uphold_verified
      get :statement
      get :statement_ready
      get :contact_info
      get :domain_status
      patch :verify
      patch :check_for_https
      patch :update
      patch :generate_statement
      patch :update_unverified
      patch :complete_signup
      get :choose_new_channel_type
      resources :two_factor_authentications, only: %i(index)
      resources :two_factor_registrations, only: %i(index) do
        collection do
          get :prompt
        end
      end
      resources :u2f_registrations, only: %i(new create destroy)
      resources :u2f_authentications, only: %i(create)
      resources :totp_registrations, only: %i(new create destroy)
      resources :totp_authentications, only: %i(create)
    end
  end
  devise_for :publishers, only: :omniauth_callbacks, controllers: { omniauth_callbacks: "publishers/omniauth_callbacks" }

  resources :channels, only: %i(destroy) do
    member do
      delete :destroy
    end
  end

  resources :site_channels, only: %i(create update new show) do
    member do
      patch :update_unverified
      patch :check_for_https
      patch :verify
      get :download_verification_file
      get :verification_choose_method
      get :verification_dns_record
      get :verification_public_file
      get :verification_github
      get :verification_wordpress
      get :verification_support_queue
    end
  end

  resources :static, only: [] do
    collection do
      get :index
    end
  end

  root "static#index"

  namespace :api do
    resources :owners, format: false, only: %i(), constraints: { owner_id: %r{[^\/]+} } do
      resources :channels, only: %i(), constraints: { channel_id: %r{[^\/]+} } do
        get "/", action: :show
        patch "verifications", action: :verify
        post "notifications", action: :notify
      end
    end
  end

  resources :errors, only: [], path: "/" do
    collection do
      get "400", action: :error_400
      get "401", action: :error_401
      get "403", action: :error_403
      get "404", action: :error_404
      get "422", action: :error_422
      get "500", action: :error_500
    end
  end

  require "sidekiq/web"
  if Rails.env.production?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks: (https://codahale.com/a-lesson-in-timing-attacks/)
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use `secure_compare` to stop length information leaking
      ActiveSupport::SecurityUtils.secure_compare(username, ENV["SIDEKIQ_USERNAME"]) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV["SIDEKIQ_PASSWORD"])
    end
  end
  mount Sidekiq::Web, at: "/magic"
end
