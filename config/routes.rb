RailsOSRM::Application.routes.draw do

  #signup, login, logout
  get "signup" => "users#new", :as => :signup
  get "login" => "sessions#new", :as => :login
  get "login/return" => "sessions#new_and_return", :as => :login_and_return
  get "logout" => "sessions#destroy", :as => :logout
  resources :sessions, :path => :login, :except => :index do
    collection do
      get 'unverified'
      get 'existing'
    end
  end
  
  resource :account do
    get 'activating'
    get 'welcome'
    get 'settings'
    post 'settings' => :update_settings
  end
  get 'account/password/change' => 'accounts#edit_password', :as => :edit_password
  put 'account/password' => 'accounts#update_password', :as => :update_password  
  delete 'account/logins/:id' => 'accounts#destroy_oath_login', :as => :destroy_oath_login
  #get 'account/activate/resend' => 'accounts#new_activation', :as => :new_activation
  #post 'account/activate/resend' => 'accounts#create_activation', :as => :create_activation

  resources :users

  resources :emails, :path => 'account/emails' do
    collection do
      match ':token/verify' => :verify, :as => :verify_by_token
      get 'verify' => :new_verification
      post 'verify' => :create_verification
      get 'unverified'
      get 'verification_sent'
    end
    member do
      get 'verify/resend' => :resend_verification, :as => :resend_verification
    end
  end

  resources :password_resets, :except => [:index,:edit], :path => 'account/password/reset' do
    collection do
      match ':token/edit' => :edit, :as => :reset_by_token
    end
    get 'unverified', :on => :collection
  end
  
  resources :blogs, :controller => :blog, :as => :blog_entry, :path => :blog do
    collection do
      get 'archive' => :archive
      get 'tag/:tag' => :tag
    end
  end
  resources :comments, :only => [:destroy]
  match 'comments/:commentable_type/:commentable_id' => 'comments#create', :via => :post

  match 'follows/:followable_type/:followable_id' => 'follows#follow', :via => :post
  match 'follows/:followable_type/:followable_id' => 'follows#unfollow', :via => :delete
  
  
  resources :issues, :path => 'lab' do
    member do
      post 'vote'
      post 'unvote'
    end
    collection do
      get 'list'
      get 'cards'
    end
  end
  
  
  match '/ping' => 'pages#ping'
  
  match '/:locale' => 'pages#index'
  root :to => 'map#index'


  #404 catch all. https://github.com/rails/rails/issues/671
  match '*path' => 'application#route_not_found'  
end
