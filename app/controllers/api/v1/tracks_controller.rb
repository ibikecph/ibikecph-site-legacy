class Api::V1::TracksController < Api::V1::BaseController

  load_and_authorize_resource :user
  load_and_authorize_resource :track

  def index
    @tracks = current_user.tracks
  end

  def create
    @track = Track.new track_params

    if @track.save
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

  private

  def track_params
    params.require(:track).permit(
      :start_date,
      :from_name,
      :to_name,
      coordinates_attributes: [
          :timestamp,
          :latitude,
          :longtitude
      ]
    )
  end
end