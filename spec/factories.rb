FactoryGirl.define do
  factory :reported_issue do
    comment "sux"
    error_type "problemz"
  end

  factory :user do
    name 'Moby Dick'
    email 'moby@dick.com'

    after :build do |u|
      u.email_confirmation = u.email
      u.password = u.password_confirmation = 'password'
    end
  end
end
