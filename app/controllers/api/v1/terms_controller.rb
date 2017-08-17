class Api::V1::TermsController < Api::V1::BaseController
  
  skip_before_action :check_auth_token!, raise: false
  
  def index
    render status: 200,
           json: {
             version: ENV['TERMS_VERSION'],
             important_parts_description_da: t("mobileterms.v#{ENV['TERMS_VERSION']}.important_parts_description", locale: :da),
             important_parts_description_en: t("mobileterms.v#{ENV['TERMS_VERSION']}.important_parts_description", locale: :en)
           }
    
  end

end
