class OAuthAuthentication < Authentication
  
  before_create { activate }
  
  def name
    provider.titleize
  end
  
end