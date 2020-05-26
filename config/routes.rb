Rails.application.routes.draw do
  resources :entries do
    resources :postings, except: [:index]
  end
  resources :accounts

  get 'pages/beancount'
  get 'pages/import'
  post 'pages/import', controller: :pages, action: :parse

  root "entries#index" 
end
