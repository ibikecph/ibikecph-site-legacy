class Api::V1::TermsController < Api::V1::BaseController
  
  skip_before_filter :check_auth_token!
  
  def index
    if stale?(last_modified: TERMS_LAST_MODIFIED)
      render status: 200,
             json: {
               important_parts_description_da: t("user_terms.summary", locale: :da),
               important_parts_description_en: t("user_terms.summary", locale: :en),
               full_text_da: t("user_terms.full_text", locale: :da),
               full_text_en: t("user_terms.full_text", locale: :en)
             }
    end
    
  end
  
end
