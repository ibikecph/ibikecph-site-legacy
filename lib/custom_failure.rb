class CustomFailure < Devise::FailureApp

def respond 
	if request.format=="json" 
		json_failure 
	else 
		super 
	end 
end

def json_failure
	self.status = 401 
	self.content_type = 'json' 
	self.response_body = "{'success':false,'info':'#{ I18n.locale==:en ? 'Please confirm your account.' : 'Bekræft venligst din konto.' }','errors':'#{ I18n.locale==:en ? 'Please confirm your account.' : 'Bekræft venligst din konto.' }'}"
end 
  
end