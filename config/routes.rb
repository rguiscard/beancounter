Rails.application.routes.draw do
  resources :entries do
    resources :postings, except: [:index]
  end
  resources :accounts, except: [:new, :create]

  get 'pages/beancount'
  get 'pages/input'
  post 'pages/import'
  get 'pages/guide'

  root "entries#index" 
end
