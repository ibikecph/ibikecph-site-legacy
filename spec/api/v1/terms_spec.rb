require 'rails_helper'

describe 'Terms API', api: :v1 do

  context 'should' do
    it 'get terms if HTTP_IF_MODIFIED_SINCE is not set' do
      get "/api/terms", {}, headers
      expect(response).to be_success
      expect(response).to have_http_status(200)
      expect(response.headers['Last-Modified']).to eq( TERMS_LAST_MODIFIED.httpdate )
      expect(json['important_parts_description_da']).to eq( I18n.t("user_terms.summary", locale: :da) )
      expect(json['important_parts_description_en']).to eq( I18n.t("user_terms.summary", locale: :en) )
      expect(json['full_text_da']).to eq( I18n.t("user_terms.full_text", locale: :da) )
      expect(json['full_text_en']).to eq( I18n.t("user_terms.full_text", locale: :en) )
    end
  end

  it 'return 304 Not Modified if HTTP_IF_MODIFIED_SINCE is later than modifed date' do
    fetched = TERMS_LAST_MODIFIED + 1.minute
    get "/api/terms", {}, headers.merge( "HTTP_IF_MODIFIED_SINCE": fetched.httpdate )
    expect(response).to have_http_status(304)
    expect(response.headers['Last-Modified']).to eq( TERMS_LAST_MODIFIED.httpdate )
  end

  it 'return terms if HTTP_IF_MODIFIED_SINCE is earlier than modifed date' do
    fetched = TERMS_LAST_MODIFIED - 1.minute
    get "/api/terms", {}, headers.merge( "HTTP_IF_MODIFIED_SINCE": fetched.httpdate )
    expect(response).to be_success
    expect(response).to have_http_status(200)
    expect(response.headers['Last-Modified']).to eq( TERMS_LAST_MODIFIED.httpdate )
    expect(json['important_parts_description_da']).to eq( I18n.t("user_terms.summary", locale: :da) )
    expect(json['important_parts_description_en']).to eq( I18n.t("user_terms.summary", locale: :en) )
    expect(json['full_text_da']).to eq( I18n.t("user_terms.full_text", locale: :da) )
    expect(json['full_text_en']).to eq( I18n.t("user_terms.full_text", locale: :en) )
  end
end
