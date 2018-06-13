# coding: utf-8
FactoryBot.define do

  sequence(:title) { |n| "Title#{n}" }
  sequence(:name)  { |n| "Person#{n}" }
  sequence(:email) { |n| "person#{n}@example.com" }
  sequence(:seconds_passed) {|n| n*3}
  sequence(:count) {|n| n}

  factory :user do
    name
    email
    after :build do |u|
      u.email_confirmation = u.email
      u.password = u.password_confirmation = 'password'
    end
  end

  factory :user_with_facebook, class: :user do
    name
    email
    provider 'facebook'

    after :build do |u|
      u.email_confirmation = u.email
      u.skip_confirmation!
      u.reset_authentication_token!
    end
  end

  factory :issue do
    title
    body "Call me Ishmael..."
  end

  factory :reported_issue do
    comment "sux"
    error_type "problemz"
  end

  factory :route do
    from_name 'Vestergade 27-29, 1550 København V'
    from_latitude '55.677276'
    from_longitude '12.569467'

    to_name 'Lille Kannikestræde 3, 1170 København K'
    to_latitude '55.679998'
    to_longitude '12.574735'

    start_date Date.new
  end

  factory :favourite do
    name 'Fav'
    address 'Vestergade 27-29, 1550 København V'
    latitude '55.677276'
    longitude '12.569467'
    source 'favorite'
    sub_source 'favorite'
  end

  factory :privacy_token do
    email 'email@ibikecph.dk'
    password 'password'

    factory :privacy_token_new do
      current_password 'password'
      password 'password123'
    end
  end

end
