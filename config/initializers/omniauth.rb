Rails.application.config.middleware.use OmniAuth::Builder do
  
  if Rails.env.development?
    provider :developer, :fields => [:role], :uid_field => :role
  end
  
  provider :twitter, TWITTER_CLIENT_ID, TWITTER_CLIENT_SECRET, :setup => true
  provider :facebook, FACEBOOK_CLIENT_ID, FACEBOOK_CLIENT_SECRET, :setup => true, :client_options => FACEBOOK_CLIENT_OPTIONS  
end  
