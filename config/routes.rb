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

  resources :accounts, except: [:new, :create] do
    member do
      get 'settings'
      get 'confirm_destroy'
      delete 'complete_destroy'
    end
  end

  get 'beancount', to: 'pages#beancount'
  get 'statistics', to: 'pages#statistics'
  get 'guide', to: 'pages#guide'
  get 'welcome', to: 'pages#welcome'

  authenticated :user do
    root 'entries#transactions', as: :user_root
  end

  root "pages#welcome"
end
