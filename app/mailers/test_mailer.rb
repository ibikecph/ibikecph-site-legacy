class TestMailer < ActionMailer::Base
  default from: 'test@test.com'

  def test address
    mail to: address, subject: 'test subject'
  end

end
