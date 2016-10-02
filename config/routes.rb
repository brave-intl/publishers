Rails.application.routes.draw do
  resources :publishers, only: %i(new create) do
    collection do
      get :current
      get :payment_info
      patch :payment_info, action: :update_payment_info, as: :update_payment_info
    end
  end
  devise_for :publishers

  root "publishers#new"
end
