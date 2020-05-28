Rails.application.routes.draw do
  devise_for :users, only: :sessions

  resources :entries do
    resources :postings, except: [:index]

    get 'transactions', on: :collection
    get 'search', on: :collection
  end

  resources :accounts, except: [:new, :create] do
    get 'balances', on: :collection
  end

  get 'beancount', to: 'pages#beancount'
  get 'pages/input'
  post 'pages/import'
  get 'guide', to: 'pages#guide'
  get 'welcome', to: 'pages#welcome'

  authenticated :user do
    root 'entries#index', as: :user_root
  end

  root "pages#welcome"
end
