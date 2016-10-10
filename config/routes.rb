Rails.application.routes.draw do
  resources :publishers, only: %i(create new show) do
    collection do
      get :download_verification_file
      get :home
      get :log_out
      get :payment_info, action: :edit_payment_info, as: :edit_payment_info
      patch :payment_info, action: :update_payment_info, as: :update_payment_info
      get :verification
      patch :verify
    end
  end
  devise_for :publishers

  resources :publisher_legal_forms, only: %i(create show), path: "legal_forms" do
    collection do
      get :after_sign
    end
  end

  resources :static, only: [] do
    collection do
      get :index
    end
  end

  root "static#index"
end
