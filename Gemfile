source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'jquery-rails'
gem 'i18n-js'
gem 'cancan', :git => 'git://github.com/emiltin/cancan.git', :branch => 'master'
gem 'pg'
gem 'carrierwave'
gem 'mini_magick'
gem 'fog'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'delayed_job_active_record'
gem 'simple-navigation'
gem 'will_paginate'
gem 'thin'
gem 'auto_html', :require => 'auto_html', :git => 'git://github.com/emiltin/auto_html.git', :branch => 'master'   #:path => '~/code/auto_html'
gem 'rails_autolink'
gem 'acts-as-taggable-on'
gem 'exception_notification', '2.6.1'   #there's UTF bug with 3.0.0
gem 'google-analytics-rails'
gem 'rails-timeago'
gem 'devise'
gem 'jbuilder'

group :development do
  gem 'quiet_assets'
end

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails'
  gem 'uglifier'
  gem 'eco'
end

group :production, :staging do
  gem 'workless', '~> 1.1.1'
  gem 'newrelic_rpm'    #place low in list to allow other stuff to be instrumented
end
