class Api::V1::ConfirmationsController < Devise::ConfirmationsController
 

def create
  @user = User.where(:email => params[:user][:email]).first
  if @user && @user.confirmed_at.nil?
    @user.send_confirmation_instructions
      render :status => 200,
           :json => { :success => true,
                      :info => t('devise.confirmations.send_instructions'),
                      :data => {} }
  else
        render :status => 404,
           :json => { :success => false,
                      :info => t('accounts.flash.email_not_found'),
                      :errors => t('accounts.flash.email_not_found')}
  end
end
end