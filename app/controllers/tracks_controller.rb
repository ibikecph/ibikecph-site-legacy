class TracksController < ApplicationController
  def delete_all
    if current_user.valid_password?(params[:user][:password])
      Track.delete_all_by_info(current_user.email, params[:user][:password], current_user.track_count)
      redirect_to account_path, notice: 'Tracks deleted'
    else
      redirect_to tracks_account_path, alert: t('accounts.tracks.wrong_password')
    end
  end
end