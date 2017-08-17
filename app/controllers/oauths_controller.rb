class OauthsController < ApplicationController

  skip_before_action :require_login, raise: false

end
