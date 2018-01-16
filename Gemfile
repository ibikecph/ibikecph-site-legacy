source 'https://rubygems.org'

ruby '2.4.1'

gem "rails"
gem 'pg', '~> 0.20'

gem 'bcrypt', require: 'bcrypt'
gem 'devise'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'devise-token_authenticatable'
gem 'cancancan'

gem 'backbone-rails'
gem 'jquery-rails'
gem 'i18n-js', '~> 3.0.0.rc13'
gem 'carrierwave'
gem 'mini_magick'
gem 'fog-aws'
gem 'delayed_job_active_record'
gem 'simple-navigation'
gem 'puma'
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
gem 'redcarpet'
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

  # origin repo in unmaintained, this fork fixes a problem with rails 5
  gem 'workless', git: "https://github.com/vfonic/workless.git", ref: '9c66a42'
  gem 'newrelic_rpm'
end
