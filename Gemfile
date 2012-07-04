source 'https://rubygems.org'

gem 'rails', '3.2.6'
gem 'jquery-rails'
gem 'i18n-js'
gem 'cancan', :git => 'git://github.com/emiltin/cancan.git', :branch => 'master'
gem 'pg'
gem 'carrierwave'
gem 'rmagick'
gem 'fog'
gem 'bcrypt-ruby', :require => 'bcrypt'
gem 'delayed_job_active_record'
gem 'simple-navigation'
gem 'will_paginate'
gem 'thin'
gem 'auto_html', :require => 'auto_html', :git => 'git://github.com/emiltin/auto_html.git', :branch => 'master'   #:path => '~/code/auto_html'
gem 'rails_autolink'
gem 'acts-as-taggable-on'
gem 'exception_notification'
gem 'google-analytics-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'eco'
end

group :production, :staging do
  gem 'workless', '~> 1.0.1'
  gem 'newrelic_rpm'    #place low in list to allow other stuff to be instrumented
end
