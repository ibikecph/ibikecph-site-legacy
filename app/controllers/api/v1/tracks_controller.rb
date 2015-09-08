class Api::V1::TracksController < Api::V1::BaseController

  #TODO create strings for all messages

  before_action :check_privacy_token, only: [:index, :destroy]

  load_and_authorize_resource :user
  load_and_authorize_resource :track

  def index
    @tracks = Track.find_all_by_signature privacy_token, current_user.track_count
  end

  def create
    @track = Track.new track_params

    if @track.save_and_update_count(current_user) && @track.coordinates.count.to_s == params[:track][:coord_count].try(:to_s)
      render status: 201,
             json: {
                 success: true,
                 info: t('routes.flash.created'),
                 data: { id: @track.id, count: @track.coordinates.count }
             }
    else
      render status: 422,
             json: {
                 success: false,
                 info: @track.errors.full_messages.first,
                 errors: @track.errors.full_messages
             }
    end
  end

  def destroy
    @track = Track.find_by_id(params[:id])

    if @track
      if @track.validate_ownership(privacy_token, current_user.track_count)
        if @track.destroy
          render status: 200,
                 json: {
                     success: true,
                     info: t('routes.flash.deleted'),
                     data: {}
                 }
        end
      else
        render status: 401,
               json: {
                   success: true,
                   info: t('api.flash.unauthorized'),
                   data: t('api.flash.unauthorized')
               }
      end
    else
      render status: 404,
             json: {
                 success: false,
                 info: t('routes.flash.route_not_found'),
                 errors: t('routes.flash.route_not_found')
             }
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
    @token ||= params[:signature]
  end
end