class Api::V1::FavouritesController < Api::V1::BaseController

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  load_and_authorize_resource :user
  load_and_authorize_resource :favourite

  def index
    @favourites = current_user.favourites.all_favourites
  end

  def create
    check_favourite_encoding!

    @favourite = current_user.favourites.new favourite_params
    @favourite.position = current_user.favourites.length

    if @favourite.save
      render status: 201,
             json: {
               success: true,
               info: t('favourites.flash.created'),
               data: { id: @favourite.id }
             }
    else
      render status: 422,
             json: {
               success: false,
               info: @favourite.errors.full_messages.first,
               errors: @favourite.errors.full_messages
             }
    end
  end

  def show
    @favourite = current_user.favourites.find(params[:id])

    unless @favourite
      render status: 404,
             json: {
               success: false,
               info: t('favourites.flash.fav_not_found'),
               errors: t('favourites.flash.fav_not_found')
             }
    end
  end

  def update
    @favourite = current_user.favourites.find_by id: params[:id]

    unless @favourite
      render status: 404,
             json: {
               success: false,
               info: t('favourites.flash.fav_not_found'),
               errors: t('favourites.flash.fav_not_found')
             }
    else
      check_favourite_encoding!

      if @favourite.update_attributes(favourite_params)
        render status: 200,
               json: {
                 success: true,
                 info: t('favourites.flash.updated'),
                 data: { id: @favourite.id }
               }
      else
        render status: 400,
               json: {
                 success: false,
                 info: @favourite.errors.full_messages.first,
                 errors: @favourite.errors.full_messages
               }
      end
    end
  end

  def destroy
    @favourite = current_user.favourites.find_by id: params[:id]

    if @favourite
      @favourite.destroy
      render status: 200,
             json: {
               success: true,
               info: t('favourites.flash.deleted'),
               data: {}
             }
    else
      render status: 404,
             json: {
               success: false,
               info: t('favourites.flash.fav_not_found'),
               errors: t('favourites.flash.fav_not_found')
             }
    end
  end

  def reorder
    @pos_ary = params[:pos_ary]

    if params[:pos_ary] && params[:pos_ary].length > 0
      @pos_ary = params[:pos_ary]

      @pos_ary.each do |fav|
        @fav = current_user.favourites.find(fav[:id]) if fav.length == 2
        @fav.update_attributes(position: fav[:position]) if @fav
      end
    end

    # we only consider success case only
    render status: 200,
           json: {
             success: true,
             info: t('favourites.flash.position_updated'),
             data: { user_id: current_user.id }
           }
  end

  private

  def favourite_params
    # preserve backwards compatability
    if !params[:favourite][:lattitude].nil? && params[:favourite][:latitude].nil?
      params[:favourite][:latitude] = params[:favourite][:lattitude]
    end

    params.require(:favourite).permit(
      :name,
      :address,
      :latitude,
      :longitude,
      :source,
      :sub_source,
      :position
    )
  end

  def check_favourite_encoding!
    if params[:favourite] &&
       params[:favourite][:address] &&
       !params[:favourite][:address].force_encoding('UTF-8').valid_encoding?

      params[:favourite][:address] = params[:favourite][:address]
                                     .force_encoding('ISO-8859-1')
                                     .encode('UTF-8')
    end
    if params[:favourite] &&
       params[:favourite][:name] &&
       !params[:favourite][:name].force_encoding('UTF-8').valid_encoding?

      params[:favourite][:name] = params[:favourite][:name]
                                  .force_encoding('ISO-8859-1')
                                  .encode('UTF-8')
    end
  end

end
