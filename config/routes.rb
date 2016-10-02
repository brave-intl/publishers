Rails.application.routes.draw do
  resources :publishers, only: %i(new create) do
    collection do
      get :current
    end
  end
  devise_for :publishers

  root "publishers#new"
end
