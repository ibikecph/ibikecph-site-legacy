class Api::V1::RegistrationsController < Devise::RegistrationsController

  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }

  def new
    @user = User.new
  end

  def create
    # never allow new users with a role
    params[:user].delete(:role)

    check_user_encoding!

    # handle images
    if params[:user][:image_path] && params[:user][:image_path]['file']
      prepare_image_data(params[:user][:image_path])
    end

    @user = User.new user_params

    if @user.save
      # auto_login @user
      # logged_in account_path, notice: "Account created. Welcome!"
      @user.reset_authentication_token!

      render status: 201,
             json: {
               success: true,
               info: t('users.flash.activate_account'),
               data: {}
             }
    else
      render status: 422,
             json: {
               success: false,
               info: @user.errors.full_messages.first,
               errors: @user.errors.full_messages
             }

    end
  end

  def update
    @user = User.find_by id: params[:id]

    unless @user
      render status: 404,
             json: {
               success: false,
               info: t('users.flash.user_not_found'),
               errors: t('users.flash.user_not_found')
             }
    else
      if params[:user][:image_path] && params[:user][:image_path]['file']
        prepare_image_data(params[:user][:image_path])
      end

      if @user.update_with_password(user_params)
        render status: 200,
               json: {
                 success: true,
                 info: t('users.flash.updated'),
                 data: { id: @user.id }
               }
      else
        render status: 400,
               json: {
                 success: false,
                 info: @user.errors.full_messages.first,
                 errors: @user.errors.full_messages
               }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(
      :name,
      :about,
      :email,
      :email_confirmation,
      :password,
      :password_confirmation,
      :image,
      :image_path,
      :remove_image,
      :image_cache,
      :notify_by_email,
      :terms,
      :tester,
      :provider,
      :uid,
      :account_source,
      :email_confirmation
    )
  end

  def warn_about_existing_name
    user = User.find_by(name: @user.name)

    if user
      @name = @auth['info']['name']
      render :existing_name
    end
  end

  def prepare_image_data(image_path_params)
    tempfile = Tempfile.new('fileupload')
    tempfile.binmode
    tempfile.write(Base64.decode64(image_path_params['file']))

    uploaded_file = ActionDispatch::Http::UploadedFile.new(
      tempfile: tempfile,
      filename: image_path_params['filename'],
      original_filename: image_path_params['original_filename']
    )
    params[:user][:image] = uploaded_file

    tempfile.delete
  end

  def check_user_encoding!
    if params[:user] &&
       params[:user][:name] &&
       !params[:user][:name].force_encoding('UTF-8').valid_encoding?

      params[:user][:name] = params[:user][:name]
                             .force_encoding('ISO-8859-1')
                             .encode('UTF-8')
    end
    if params[:user] &&
       params[:user][:password] &&
       !params[:user][:password].force_encoding('UTF-8').valid_encoding?

      params[:user][:password] = params[:user][:password]
                                 .force_encoding('ISO-8859-1')
                                 .encode('UTF-8')
    end
    if params[:user] &&
       params[:user][:password_confirmation] &&
       !params[:user][:password_confirmation].force_encoding('UTF-8').valid_encoding?

      params[:user][:password_confirmation] = params[:user][:password_confirmation]
                                              .force_encoding('ISO-8859-1')
                                              .encode('UTF-8')
    end
  end

end
