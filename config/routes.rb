Rails.application.routes.draw do
  resources :accounts

  resources :entries do
    resources :postings, except: [:index]
  end

  root "entries#index" 
end
