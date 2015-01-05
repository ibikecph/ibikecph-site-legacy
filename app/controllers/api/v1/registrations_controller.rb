class Api::V1::RegistrationsController < Devise::RegistrationsController

  skip_before_filter :verify_authenticity_token, if: Proc.new { |c| c.request.format == 'application/json' }

  def new
    @user = User.new
  end

  def create
    # never allow new users with a role
    params[:user].delete(:role)
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

    # handle images
    if params[:user][:image_path] && params[:user][:image_path]['file']
      prepare_image_data(params[:user][:image_path])
    end

    @user = User.new params[:user]

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
    @user = User.find_by_id(params[:id])

    if params[:user][:image_path] && params[:user][:image_path]['file']
      prepare_image_data(params[:user][:image_path])
    end

    if @user.update_with_password(params[:user])
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

  private

  def warn_about_existing_name
    user = User.find_by_name @user.name

    if user
      @name = @auth['info']['name']
      render :existing_name
    end
  end

  def find_user
    @user = User.find params[:id]
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

end
