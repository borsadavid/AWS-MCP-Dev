Rails.application.routes.draw do
  root to: "expenses#index"

  resources :expenses, only: [:index, :create, :new, :destroy] do
    collection do
      post :query
    end
  end
end
