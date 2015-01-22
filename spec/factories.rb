FactoryGirl.define do
  factory :issue do
    title "Moby Dick"
    body "Call me Ishmael..."
  end

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
