# typed: ignore
# These are the routes for the application
#
# As a general rule; resources should never be nested more than 1 level deep.
# For solutions regarding - https://guides.rubyonrails.org/routing.html#limits-to-nesting
#
# For more general information check out this guide
# https://guides.rubyonrails.org/routing.html
Rails.application.routes.draw do
  get "health-check", to: "health_checks#show"

  # Legacy routes based off OAuth connections. We will update our OAuth providers information, but need these until we do.
  get "publishers/uphold_verified", to: "payment/connection/uphold_connections#edit"
  get "publishers/gemini_connection/new", to: "payment/connection/gemini_connections#edit"

  get "publishers/stripe_connection/new", to: "payment/connection/stripe_connections#edit"
  get "publishers/paypal_connections/connect_callback", to: "payment/connection/paypal_connections#connect_callback"

  # oauth_controller base children
  get "publishers/bitflyer_connection/new", to: "payment/connection/bitflyer_connections#callback"
  # CSP
  post "csp-violation-report", to: "csp_violations_report#create"

  # Routes for Browser Users to login via Uphold
  namespace :uphold_connections do
    get :login
    get :confirm
  end

  # Homepage for Browser Users
  namespace :browser_users do
    get :home
    put :accept_tos
  end

  # This implements basic callback urls for initiating oauth flows.
  # It could endup being a base/abstract controller for any authorization code flow
  # For right now I needed it to test/debug flows locally
  if Rails.env.development?
    namespace :oauth2 do
      get ":provider/code", action: :code
      get ":provider/callback", action: :callback
    end
  end

  # These routes are for connecting to 3rd-party payment providers.
  namespace :connection, module: "payment/connection" do
    resource :currency, only: [:show, :update]
    resource :stripe_connection
    resource :gemini_connection
    resource :bitflyer_connection
    resource :uphold_connection, except: [:new]

    resources :paypal_connections, only: [] do
      get :connect_callback, on: :collection
      get :refresh
      patch :disconnect
    end
  end

  # Once Publisher Logs in they access this resource
  resources :publishers, only: %i[create update new show destroy] do
    collection do
      scope module: "publishers" do
        # Registrations, eventually we should consider refactoring these routes into something a little more restful
        scope controller: "registrations" do
          get :sign_up
          get :log_in
          get :expired_authentication_token
          post :resend_authentication_email

          resource :registrations, only: [:create, :update]
        end

        resource :case do
          delete :delete_file
        end
        resources :case_notes
        resources :keys do
          patch :roll
        end

        resources :statements, only: [:index, :show] do
          get :rate_card, on: :collection
        end

        resource :two_factor_authentications_removal

        resource :wallet do
          get :latest
        end

        resources :promo_registrations, only: [:index, :create] do
          collection do
            get :for_referral_code
            get :overview
          end
        end
      end

      post :log_out
      get :home
      get :home_balances
      get :uphold_wallet_panel
      get :paypal_wallet_panel
      get :change_email
      get :change_email_confirm
      patch :update_email
      get :email_verified
      get :suspended_error
      get :get_site_banner_data
      patch :verify
      patch :update
      patch :complete_signup
      post :create_new_untethered_referral_code
      get :choose_new_channel_type
      get :security, to: "publishers/security#index"
      get :prompt_security, to: "publishers/security#prompt"
      get :settings, to: "publishers/settings#index"
      resources :two_factor_authentications, only: %i[index]
      resources :u2f_registrations, only: %i[new create destroy]
      resources :u2f_authentications, only: %i[create]
      resources :totp_registrations, only: %i[new create destroy]
      resources :totp_authentications, only: %i[create]
    end

    member do
      get :ensure_email
      post :ensure_email_confirm
    end

    resources :site_banners, controller: "publishers/site_banners" do
      collection do
        post :set_default_site_banner_mode
      end
    end
  end

  devise_for :publishers, only: :omniauth_callbacks, controllers: {omniauth_callbacks: "publishers/omniauth_callbacks"}

  resources :channels, only: %i[destroy] do
    member do
      get :verification_status
      get :cancel_add
      delete :destroy
      resources :tokens, only: %() do
        get :reject_transfer, to: "channel_transfer#reject_transfer"
      end
    end
  end

  resources :site_channels, only: %i[create update new show] do
    member do
      patch :update_unverified
      patch :check_for_https
      patch :verify
      get :download_verification_file
      get :verification_choose_method
      get :verification_dns_record
      get :verification_public_file
      get :verification_github
    end
  end

  resources :static, only: [] do
    collection do
      get :index
    end
  end

  resources :faqs, only: [:index]

  root "static#index"
  get "no_js", controller: "static"
  get "sign-up", to: "static#index"
  get "log-in", to: "static#index"

  namespace :api, defaults: {format: :json} do
    # /api/v1/
    namespace :v1, defaults: {format: :json} do
      resources :publishers, defaults: {format: :json} do
        post "publisher_status_updates"
      end

      # /api/v1/promo_registrations
      namespace :promo_registrations do
        post "/:referral_code/publisher_status_updates", action: "publisher_status_updates"
      end

      resources :transactions, only: [:show]

      # /api/v1/stats/
      namespace :stats, defaults: {format: :json} do
        namespace :channels, defaults: {format: :json} do
          get :twitch_channels_by_view_count
          get :youtube_channels_by_view_count
        end
        resources :channels, defaults: {format: :json}, only: %i[show]
        resources :promo_campaigns, defaults: {format: :json}, only: %i[index show]
        resources :referral_codes, defaults: {format: :json}, only: %i[index show]
        namespace :publishers, defaults: {format: :json} do
          get :signups_per_day
          get :email_verified_signups_per_day
          get :channel_and_email_verified_signups_per_day
          get :channel_uphold_and_email_verified_signups_per_day
          get :channel_and_kyc_uphold_and_email_verified_signups_per_day
          get :javascript_enabled_usage
          get :totals
        end
      end
      # /api/v1/public/
      namespace :public, defaults: {format: :json} do
        get "channels", controller: "channels"
        namespace :channels, defaults: {format: :json} do
          get "totals"
        end
      end
    end
    # /api/v2/
    namespace :v2, defaults: {format: :json} do
      namespace :public, defaults: {format: :json} do
        get "channels", controller: "channels"
        namespace :channels, defaults: {format: :json} do
          get "totals"
        end
      end
    end
    # /api/v3/
    namespace :v3, defaults: {format: :json} do
      namespace :public, defaults: {format: :json} do
        get "channels", controller: "channels"
        namespace :channels, defaults: {format: :json} do
          get "totals"
        end
      end
    end

    # /api/v3_p1/
    namespace :v3_p1, defaults: {format: :json} do
      namespace :public, defaults: {format: :json} do
        get "channels", controller: "channels"
      end
    end
  end

  namespace :admin do
    resources :channels, only: [:index, :destroy] do
      collection do
        get :duplicates
      end
    end

    resources :cases do
      patch :assign
      collection do
        get :overview
        resources :case_replies
      end
    end

    resources :case_notes

    resources :faq_categories, except: [:show]
    resources :faqs, except: [:show]
    resources :payout_reports do
      collection do
        post :notify
        post :upload_settlement_report
        put :payouts_in_progress
      end
      member do
        get :download
        patch :refresh
      end
    end
    resources :publishers do
      get :wallet_info
      resources :invoices, module: "publishers" do
        post :upload
        get :finalize
        patch :update_status
        post :archive_file
      end

      collection do
        patch :approve_channel
        get :statement
        get :cancel_two_factor_authentication_removal
      end
      get :sign_in_as_user

      resources :payments
      patch :refresh_uphold

      resources :publisher_notes
      resources :publisher_whitelist_updates, controller: "publishers/publisher_whitelist_updates"
      resources :publisher_status_updates, controller: "publishers/publisher_status_updates"
      resources :referrals, controller: "publishers/referrals"
      resources :reports
    end
    resources :channel_transfers
    resources :channel_approvals
    resources :security

    resources :organizations, except: [:destroy]

    namespace :stats do
      resources :contributions, only: [:index]
      resources :referrals, only: [:index]
      resources :top_balances, only: [:index]
      resources :top_youtube_channels, only: [:index]
      resources :publisher_statistics, only: [:index]
    end
    resources :unattached_promo_registrations, only: %i[index create] do
      collection do
        get :report, defaults: {format: :csv}
        patch :update_statuses
        patch :assign_campaign
        put :assign_installer_type
      end
    end
    resources :promo_campaigns, only: %i[create]
    root to: "dashboard#index" # <--- Root route

    resources :uphold_status_reports, only: [:index, :show]
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
  if Rails.env.production? || Rails.env.staging?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      # Protect against timing attacks: (https://codahale.com/a-lesson-in-timing-attacks/)
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use `secure_compare` to stop length information leaking
      ActiveSupport::SecurityUtils.secure_compare(username, ENV["SIDEKIQ_USERNAME"]) &
        ActiveSupport::SecurityUtils.secure_compare(password, ENV["SIDEKIQ_PASSWORD"])
    end
  end
  mount Sidekiq::Web, at: "/magic"
  require "sidekiq/api"
  match "mailer-queue-status" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new("mailer").size < 100 ? "OK" : "UHOH"]] }, :via => :get
  match "default-queue-status" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new("default").size < 5000 ? "OK" : "UHOH"]] }, :via => :get
  match "scheduler-queue-status" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new("scheduler").size < 5000 ? "OK" : "UHOH"]] }, :via => :get
  match "transactional-queue-status" => proc { [200, {"Content-Type" => "text/plain"}, [Sidekiq::Queue.new("transactional").size < 5000 ? "OK" : "UHOH"]] }, :via => :get
end
