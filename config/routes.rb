RailsOSRM::Application.routes.draw do

  # api
  namespace :api, defaults: { format: 'json' } do
    scope module: :v1, constraints: ApiSettings.new(version: 1) do

      devise_for :users,
                 skip: [:sessions],
                 controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }
      as :user do
        get 'login' => 'sessions#new', as: :new_user_session
        post 'login' => 'sessions#create', as: :user_session
        delete 'logout' => 'sessions#destroy', as: :destroy_user_session
      end

      resources :reported_issues, path: 'issues'
      resources :favourites do
        collection do
          post :reorder
        end
      end
      resources :routes, :tracks
      resources :users, only: [:index, :show, :destroy]

      get   'privacy_tokens/' => 'privacy_tokens#show'
      post  'privacy_tokens/' => 'privacy_tokens#create'
      patch 'privacy_tokens/' => 'privacy_tokens#update'

      get "terms" => "terms#index"
    end
  end

  resources :token_authentications, only: [:create, :destroy]

  devise_for :users,
             skip: [:session, :password, :registration],
             controllers: { omniauth_callbacks: 'users/omniauth_callbacks' }

  scope '(:locale)', locale: /en/ do
    root to: 'map#index'

    get 'embed/cykelsupersti' => 'embed#cykelsupersti'

    get 'issues/:filter', to: 'reported_issues#index'
    resources :reported_issues, path: 'issues'

    resource :account do
      # get 'activating'
      get 'welcome'
      get 'settings'
      post 'settings' => :update_settings
    end
    get 'account/password/change' => 'accounts#edit_password', :as => :edit_password
    put 'account/password' => 'accounts#update_password', :as => :update_password
    # delete 'account/logins/:id' => 'accounts#destroy_oath_login', :as => :destroy_oath_login
    # get 'account/activate/resend' => 'accounts#new_activation', :as => :new_activation
    # post 'account/activate/resend' => 'accounts#create_activation', :as => :create_activation

    devise_for :users,
               skip: :omniauth_callbacks,
               controllers: {
                 # omniauth_callbacks: 'omniauth_callbacks',
                 registrations: 'registrations',
                 passwords: 'passwords',
                 sessions: 'sessions'
               } do
      get 'users/edit/:id' => 'devise/registrations#edit', :as => :edit_user_registration
      get 'users/new' => 'devise/registrations#new'
      get 'infopage', to: 'sessions#infopage', as: 'infopage'
    end
    resources :users

    resources :blogs, controller: :blog, as: :blog_entry, path: :blog do
      collection do
        get 'archive' => :archive
        get 'tag/:tag' => :tag
        get 'transition' => :transition
        get 'feed' => :feed, :defaults => { format: 'rss' }
      end
    end
    resources :comments, only: [:destroy]
    post 'comments/:commentable_type/:commentable_id' => 'comments#create'

    post 'follows/:followable_type/:followable_id' => 'follows#follow'
    delete 'follows/:followable_type/:followable_id' => 'follows#unfollow'

    resources :corps, only: [:index, :show] do
      collection do
        get 'join' => :join
        get 'leave' => :leave
      end
    end

    resources :issues, path: 'feedback' do
      collection do
        get 'search'
        post 'search' => :searched, :as => :post_search
        get 'cards'
        get 'tags(/:tag)' => :tags
        get 'labels(/:label)' => :labels
      end
      member do
        post 'vote'
        post 'unvote'
      end
    end

    get '/about' => 'about#index'
    get '/signal' => 'about#signal'
    get '/faq' => 'about#faq'
    get '/api' => 'about#api'
    # get '/about/:action' => 'about#:action'
  end


  get '/terms' => 'pages#terms'
  get '/help' => 'pages#help'

  get '/ping' => 'pages#ping'
  get '/fail' => 'pages#fail'

  get 'qr/:code' => 'pages#qr'

  # rail 3.2 exception handling
  get '/404', to: 'application#error_route_not_found'
  get '/500', to: 'application#error_internal_error'


  get 'medlemmer/*path' => 'blog#transition'
  get 'groupper/*path' => 'blog#transition'
  get 'cykler/*path' => 'blog#transition'
  get 'steder/*path' => 'blog#transition'
  get 'tips/*path' => 'blog#transition'
  get 'indlaeg/*path' => 'blog#transition'
  get 'cykelguide' => 'blog#transition'
end
