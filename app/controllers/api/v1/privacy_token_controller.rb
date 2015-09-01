class Api::V1::PrivacyTokenController < Api::V1::BaseController
  def create
    @token = PrivacyToken.new
    @token.signature = generate_signature(params[:email],params[:password])

    if @token.save
      render status: 201,
             json: {
                 success: true,
                 info: {},
                 data: { signature: @token.signature }
             }
    end
  end

  def update
    @token = PrivacyToken.find_by_signature(params[:signature])
    @token.update_attribute :signature, generate_signature(params[:email],params[:password])
  end

  def generate_signature(username, password)
    BCrypt::Password.new(username+password)
  end

  private

  def token_params
    #params.require(:)
  end

end