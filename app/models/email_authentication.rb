class EmailAuthentication < Authentication

  # attr_accessible :uid_confirmation

  validates_uniqueness_of :uid, case_sensitive: false
  validates_format_of :uid,
                      with: /\A[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}\z/i,
                      message: I18n.t('not_a_valid_email'),
                      allow_blank: true
  validates_presence_of :uid_confirmation, on: :create
  validates_confirmation_of :uid

  before_create do
    self.provider = 'email'
    self.state = 'unverified'
  end

  def address
    uid
  end

  def send_activation
    generate_token
    save!
    UserMailer.delay.activation(
      id, (
        I18n.locale == I18n.default_locale ? nil : I18n.locale
      )
    )
  end

  def send_verify
    generate_token
    save!
    UserMailer.delay.verify_email(
      id, (
        I18n.locale == I18n.default_locale ? nil : I18n.locale
      )
    )
  end

end
