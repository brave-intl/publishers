Rails.application.routes.draw do
  resources :publishers, only: %i(create new show) do
    collection do
      get :download_verification_file
      get :home
      get :log_out
      get :payment_info, action: :edit_payment_info, as: :edit_payment_info
      patch :payment_info, action: :update_payment_info, as: :update_payment_info
      get :verification
      get :verification_done
      patch :verify
    end
  end
  devise_for :publishers

  resources :publisher_legal_forms, only: %i(create new show), path: "legal_forms" do
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
end
