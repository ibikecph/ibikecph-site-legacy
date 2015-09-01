class Api::V1::TermsController < Api::V1::BaseController
  
  skip_before_filter :check_auth_token!
  
  def index
    render status: 200,
           json: {
             # This is not elegant.
             version: ENV['terms_version'],
             important_parts_description_da: t("mobileterms.v#{ENV['terms_version']}.important_parts_description", locale: :da),
             important_parts_description_en: t("mobileterms.v#{ENV['terms_version']}.important_parts_description", locale: :en)
           }
  end
end
