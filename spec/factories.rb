# coding: utf-8
FactoryGirl.define do

  sequence(:title) { |n| "Title#{n}" }
  sequence(:name)  { |n| "Person#{n}" }
  sequence(:email) { |n| "person#{n}@example.com" }

  factory :user do
    name
    email

    after :build do |u|
      u.email_confirmation = u.email
      u.password = u.password_confirmation = 'password'
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
end
