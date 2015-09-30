class TracksController < ApplicationController
  def delete_all
    if current_user.valid_password?(params[:user][:password])
      Track.delay.delete_all_by_info(current_user, params[:user][:password])
      redirect_to account_path, notice: t('accounts.tracks.tracks_deleted')
    else
      redirect_to tracks_account_path, alert: t('accounts.tracks.wrong_password')
    end
  end
end