RailsOSRM::Application.routes.draw do
  
  scope "(:locale)", :locale => /en/ do
    #root
    root :to => 'map#index'
    get 'embed/cykelsupersti' => 'embed#cykelsupersti'
    
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
        get 'transition' => :transition
      end
    end
    resources :comments, :only => [:destroy]
    match 'comments/:commentable_type/:commentable_id' => 'comments#create', :via => :post

    match 'follows/:followable_type/:followable_id' => 'follows#follow', :via => :post
    match 'follows/:followable_type/:followable_id' => 'follows#unfollow', :via => :delete
  
    resources :corps, :only => [:index,:show] do
      collection do
        get 'join' => :join
        get 'leave' => :leave
      end
    end  

    resources :issues, :path => 'feedback' do
      collection do
        get 'search'
        post 'search' => :searched, :as => :post_search
        get 'all'
        get 'cards'
        get 'tags(/:tag)' => :tags
        get 'labels(/:label)' => :labels
      end
      member do
        post 'vote'
        post 'unvote'
      end
    end

    resources :themes
    get 'themes/:id/new' => 'issues#new_for_theme', :as => :new_issue_for_theme
    post 'themes/:id/create' => 'issues#create_for_theme', :as => :create_issue_for_theme

  end

  match '/terms' => 'pages#terms'
  match '/help' => 'pages#help'
  
  match '/ping' => 'pages#ping'
  match '/fail' => 'pages#fail'

  match "qr/:code" => "pages#qr"

  #rail 3.2 exception handling
  match "/404", :to => "application#error_route_not_found"
  match "/500", :to => "application#error_internal_error"
    
  
  match "medlemmer/*path" => "blog#transition"
  match "groupper/*path" => "blog#transition"
  match "cykler/*path" => "blog#transition"
  match "steder/*path" => "blog#transition"
  match "tips/*path" => "blog#transition"
  match "indlaeg/*path" => "blog#transition"
  match "cykelguide" => "blog#transition"
end
