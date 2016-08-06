source 'https://rubygems.org'

ruby '2.3.0'

gem "rails", '5.0.0'
gem 'pg'

gem 'bcrypt', require: 'bcrypt'
gem 'devise', '~> 4.0.2'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'devise-token_authenticatable', '~> 0.5.1'
gem 'cancancan'

gem 'backbone-rails'
gem 'jquery-rails'
gem 'i18n-js', '~> 3.0.0.rc12'
gem 'carrierwave'
gem 'mini_magick'
gem 'fog'
gem 'delayed_job_active_record'
gem 'simple-navigation'
gem 'will_paginate'
gem 'puma'
gem 'auto_html', git: 'git://github.com/ibikecph/auto_html.git', branch: 'master'
gem 'rails_autolink'
gem 'acts-as-taggable-on', github: 'mbleigh/acts-as-taggable-on'
gem 'exception_notification'
gem 'google-analytics-rails'
gem 'rails-timeago'
gem 'jbuilder'
gem 'sass-rails'
gem 'coffee-rails'
gem 'uglifier'
gem 'eco'
gem 'recipient_interceptor'
gem 'koala'
gem 'httparty'
gem "rack-timeout"

gem 'polylines'

group :development, :test do
  gem 'dotenv-rails', :require => 'dotenv/rails-now'    # make sure this loads early
end

group :development do
  gem 'brakeman', :require => false
end

group :development, :test do
  gem 'rspec-rails'
  gem 'figaro'
end

group :test do
  gem 'factory_girl_rails'
  gem 'capybara'
  gem 'database_cleaner'
end

# place last to allow other stuff to be instrumented
group :production do
  gem 'workless'
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end
