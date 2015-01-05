source 'https://rubygems.org'

ruby '2.1.5'

gem 'rails', '3.2.19'
gem 'pg'

gem 'bcrypt-ruby', require: 'bcrypt'
gem 'devise', '2.2.5'
gem 'omniauth'
gem 'omniauth-facebook', '1.4.1'
gem 'cancan', git: 'git://github.com/mfaerevaag/cancan.git', branch: 'master'

gem 'backbone-rails'
gem 'jquery-rails'
gem 'i18n-js'
gem 'carrierwave'
gem 'mini_magick'
gem 'fog'
gem 'delayed_job_active_record'
gem 'simple-navigation'
gem 'will_paginate'
gem 'thin'
gem 'auto_html', git: 'git://github.com/mfaerevaag/auto_html.git', branch: 'master'
gem 'rails_autolink'
gem 'acts-as-taggable-on', '~> 3.4'
gem 'exception_notification'
gem 'google-analytics-rails'
gem 'rails-timeago'
gem 'jbuilder'

group :development do
  gem 'quiet_assets'
end

# asset gems not required in production
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'eco'
end

# place last to allow other stuff to be instrumented
group :production, :staging do
  gem 'workless', '~> 1.1.1'
  gem 'newrelic_rpm'
end

group :development, :test do
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails', '~> 4.0'
end
