source 'https://rubygems.org'

ruby '2.3.0'

gem "rails", '5.0.0.rc1'
gem 'pg'

gem 'bcrypt', require: 'bcrypt'
gem 'devise', '~> 4.0.2'
gem 'omniauth'
gem 'omniauth-facebook'
gem 'devise-token_authenticatable', '~> 0.5.0.beta'
gem 'cancancan'#, '~> 1.12.0'

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

group :development do
  gem 'dotenv-rails', :require => 'dotenv/rails-now'    # make sure this loads early
  gem 'quiet_assets'
  gem 'brakeman', :require => false
end

group :development, :test do
  gem 'rspec-rails'#, '~> 3.0'
  gem 'figaro'
  gem 'dotenv-rails'
end

group :test do
  gem 'factory_girl_rails'#, '~> 4.0'
  gem 'capybara'
  gem 'database_cleaner'
end

# place last to allow other stuff to be instrumented
group :production do
  gem 'workless'#, '~> 1.2.2'
  gem 'newrelic_rpm'
  gem 'rails_12factor'
end
