Rails.application.routes.draw do
  resources :publishers, only: %i(new create) do
    collection do
      get :download_verification_file
      get :home
      get :log_out
      get :payment_info
      patch :payment_info, action: :update_payment_info, as: :update_payment_info
      get :verification
    end
  end
  devise_for :publishers

  resources :static, only: [] do
    collection do
      get :index
    end
  end

  root "static#index"
end
