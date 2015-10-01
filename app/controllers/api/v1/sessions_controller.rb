class Api::V1::SessionsController < Devise::SessionsController

  skip_before_filter :check_auth_token!
  prepend_before_filter :check_login_params, only: [:create]
  prepend_before_filter :require_no_authentication, only: [:create]

  def create
    if params[:user][:fb_token]
      fb_user = Koala::Facebook::API.new(params[:user][:fb_token]).get_object('me', fields: 'id,name,email')

      if fb_user
        @user = User.find_for_facebook_user(fb_user)
        return failure unless @user

        if @user
          sign_in(:user, @user)
          success @user
        end
      else
        failure
      end
    else
      resource_class.new
      resource = User.find_for_database_authentication(email: params[:user][:email])
      return failure unless resource

      if resource.valid_password?(params[:user][:password])
        privacy_token = resource.generate_signature(params[:user][:password])
        sign_in(:user, resource)
        success resource, signature: privacy_token
      else
        failure resource
      end
    end
  end

  def destroy
    # warden.authenticate!(scope: resource_name, recall: "#{controller_path}#failure")
    # current_user.update_column(:authentication_token, nil)
    render status: 200,
           json: {
             success: true,
             info: t('sessions.flash.logged_out'),
             data: {}
           }
  end

  private

  def success(logged_user, options={})
    current_user = logged_user
    render status: 200,
           json: {
             success: true,
             info: t('sessions.flash.logged_in', user: current_user.name),
             data: ({ auth_token: logged_user.authentication_token,
                      id: logged_user.id,
                      provider: logged_user.provider
                    }.merge options)
           }
  end

  def failure(user=nil)
    render status: 401,
           json: {
             success: false,
             info: failure_message(user),
             errors: failure_message(user)
           }
  end

  def check_login_params
    sign_out current_user if current_user
    if params[:user].blank? ||
       (
         params[:user][:fb_token].blank? &&
         params[:user][:email].blank? &&
         params[:user][:password].blank?
       )

      render status: 406,
             json: {
               success: false,
               info: t('sessions.flash.invalid_attempt'),
               errors: t('sessions.flash.params_missing')
             }
    end
  end

  def failure_message(user)
    @message ||= (user && params[:user][:facebook] == 'true' && user.provider == 'facebook') ? t('sessions.flash.invalid_password') : t('sessions.flash.invalid_login')
  end

end
