Rails.application.routes.draw do
  resources :publishers, only: %i(create update new show) do
    collection do
      # Registrations, eventually we should consider refactoring these routes into something a little more restful
      scope controller: 'registrations', module: 'publishers' do
        get :sign_up
        get :log_in
        get :expired_authentication_token
        post :resend_authentication_email

        resource :registrations, only: [:create, :update]
      end

      get :log_out
      get :home
      get :change_email
      get :change_email_confirm
      patch :update_email
      patch :confirm_default_currency
      get :email_verified
      get :wallet
      get :uphold_verified
      get :suspended_error
      get :statement
      get :statements
      get :uphold_status
      get :get_site_banner_data
      patch :verify
      patch :update
      patch :complete_signup
      patch :disconnect_uphold
      get :choose_new_channel_type
      get :two_factor_authentication_removal
      post :request_two_factor_authentication_removal
      get :confirm_two_factor_authentication_removal
      get :cancel_two_factor_authentication_removal
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
      resources :promo_registrations, only: %i(index create)
    end
    resources :site_banners, controller: 'publishers/site_banners' do
      collection do
        post :set_default_site_banner_mode
      end
    end
    # (Albert Wang): Need to factor the above promo_registrations, as they should be in Publishers::PromoRegistrationsController rather than in the PromoRegistrationsController
    resources :promo_registrations, controller: 'publishers/promo_registrations', only: [] do
      collection do
        get :for_referral_code
      end
    end
  end

  namespace :partners do
    resource :payments, only: [:show] do
      resources :invoices do
        resources :invoice_files, only: [:create, :update, :destroy]
      end
    end
    resources :referrals do
      collection do
        resources :promo_registrations
        resources :promo_campaigns
      end
    end
  end

  devise_for :publishers, only: :omniauth_callbacks, controllers: { omniauth_callbacks: "publishers/omniauth_callbacks" }

  resources :channels, only: %i(destroy) do
    member do
      get :verification_status
      get :cancel_add
      delete :destroy
      resources :tokens, only: %() do
        get :reject_transfer, to: 'channel_transfer#reject_transfer'
      end
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
    end
  end

  resources :static, only: [] do
    collection do
      get :index
    end
  end

  resources :faqs, only: [:index]

  root "static#index"

  namespace :api, defaults: { format: :json } do
    # /api/v1/
    namespace :v1, defaults: { format: :json } do
      # /api/v1/stats/
      namespace :stats, defaults: { format: :json } do
        namespace :channels, defaults: { format: :json } do
          get :twitch_channels_by_view_count
          get :youtube_channels_by_view_count
        end
        resources :channels, defaults: { format: :json }, only: %i(show)
        resources :promo_campaigns, defaults: { format: :json }, only: %i(index show)
        resources :referral_codes, defaults: { format: :json }, only: %i(index show)
        namespace :publishers, defaults: { format: :json } do
          get :signups_per_day
          get :email_verified_signups_per_day
          get :channel_and_email_verified_signups_per_day
          get :channel_uphold_and_email_verified_signups_per_day
          get :javascript_enabled_usage
          get :totals
        end
      end
      # /api/v1/public/
      namespace :public, defaults: { format: :json } do
        get "channels", controller: "channels"
        namespace :channels, defaults: { format: :json } do
          get "totals"
        end
      end
    end
  end

  namespace :admin do
    resources :channels, only: [:index]
    resources :faq_categories, except: [:show]
    resources :faqs, except: [:show]
    resources :payout_reports, only: %i(index show create) do
      collection do
        post :notify
        post :upload_settlement_report
        post :toggle_payout_in_progress
      end
      member do
        get :download
        patch :refresh
      end
    end
    resources :publishers do
      collection do
        patch :approve_channel
        get :statement
        post :create_note
        get :cancel_two_factor_authentication_removal
      end
      resources :reports
      resources :publisher_status_updates, controller: 'publishers/publisher_status_updates'
    end
    resources :channel_transfers
    resources :security

    resources :organizations, except: [:destroy]
    resources :partners, except: [:destroy] do
      get :generate_manual_payout
      resources :invoices do
        post :upload
        get :finalize
        patch :update_status
      end
    end

    namespace :stats do
      resources :contributions, only: [:index]
      resources :referrals, only: [:index]
      resources :top_balances, only: [:index]
      resources :publisher_statistics, only: [:index]
    end
    resources :unattached_promo_registrations, only: %i(index create)do
      collection do
        get :report, defaults: { format: :csv }
        patch :update_statuses
        patch :assign_campaign
        put :assign_installer_type
      end
    end
    resources :promo_campaigns, only: %i(create)
    root to: "dashboard#index" # <--- Root route
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
