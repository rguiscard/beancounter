Rails.application.routes.draw do
  resources :accounts
  resources :entries

  root "entries#index" 
end
