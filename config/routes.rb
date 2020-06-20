Rails.application.routes.draw do
  devise_for :users, only: :sessions

  resources :entries do
    resources :postings, except: [:index]

    collection do
      get 'transactions'
      get 'search'
      get 'input'
      post 'import'
    end

    member do
      get 'duplicate'
    end
  end

  resources :accounts do
    member do
      get 'settings'
      get 'confirm_destroy'
      delete 'complete_destroy'
    end
  end

  resource :user, only: [:edit, :update]
  resolve("User") { [:user] } # to make form_for works properly on singular resource

  get 'beancount', to: 'pages#beancount'
  get 'beancheck', to: 'pages#beancheck'
  get 'statistics', to: 'pages#statistics'
  get 'trend', to: 'pages#trend'
  get 'guide', to: 'pages#guide'
  get 'welcome', to: 'pages#welcome'

  authenticated :user do
    root 'entries#transactions', as: :user_root
  end

  root "pages#welcome"
end
