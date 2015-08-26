class Api::V1::TracksController < Api::V1::BaseController

  load_and_authorize_resource :user
  load_and_authorize_resource :track

  def index
    @tracks = current_user.tracks
  end

  def create
    @track = Track.new track_params

    if @track.save && @count == @track.coordinates.count
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
    @count = params[:track][:coordinates_attributes].try(:count) || 0

    params.require(:track).permit(
      :timestamp,
      :from_name,
      :to_name,
      coordinates_attributes: [
          :seconds_passed,
          :latitude,
          :longitude
      ]
    )
  end

  # Support for shortened params - not working yet
  # def format_params
  #   track_attrs = params[:track]
  #
  #   formatted_params = {track: {coordinates_attributes: Array.new }}
  #
  #   formatted_params[:track][:timestamp]=track_attrs[:ts]
  #   formatted_params[:track][:from_name]=track_attrs[:fn]
  #   formatted_params[:track][:to_name]=track_attrs[:tn]
  #
  #   track_attrs[:ca].each do |x,i|
  #     formatted_params[:track][:coordinates_attributes] << {seconds_passed: x[:sp], latitude: x[:lt], longitude: x[:tg]}
  #   end
  #
  #   params[:track] = formatted_params[:track]
  # end
end