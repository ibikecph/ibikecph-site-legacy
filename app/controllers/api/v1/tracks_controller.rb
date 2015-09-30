class Api::V1::TracksController < Api::V1::BaseController

  #TODO create strings for all messages

  before_action :check_privacy_token, only: [:index, :destroy]

  load_and_authorize_resource except: [:destroy]

  def index
    @tracks = Track.find_all_by_signature privacy_token, current_user.track_count
  end

  def create
    @track = Track.new track_params

    if @track.save_and_update_count(current_user)
      created id: @track.id, count: @track.coordinates.count
    else
      failure @track
    end
  end

  def destroy
    @track = Track.find_by id: params[:id]

    return record_not_found unless @track

    authorize! :destroy, @track

    if @track.validate_ownership(privacy_token, current_user.track_count)
      if @track.destroy
        success t('routes.flash.deleted')
      end
    else
      unauthorized
    end
  end

  def token
    @signature = Track.generate_signature params[:user][:email], params[:user][:password]
  end

  private

  def track_params
    params.require(:track).permit(
      :signature,
      :timestamp,
      :from_name,
      :to_name,
      :coord_count,
      :coordinates => [:latitude,:longitude,:seconds_passed]
    )
  end

  def check_privacy_token
    unless privacy_token
      render status: 403,
             json: {
                 success: false,
                 invalid_privacy_token: true,
                 errors: t('api.flash.invalid_token')
             }
    end
  end

  def privacy_token
    @token ||= (params[:signature] || params[:track][:signature])
  end
end