Rails.application.routes.draw do
  resources :entries do
    resources :postings, except: [:index]
  end
  resources :accounts

  get 'pages/beancount'
  get 'pages/input'
  post 'pages/import'

  root "entries#index" 
end
