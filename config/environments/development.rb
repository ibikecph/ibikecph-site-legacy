RailsOSRM::Application.configure do

  #we're using www.localhost because you can't save cookies with only localhost
  #login doesn't work well unless cookies are on
  #adjust your host file to point www.localhost to 127.0.0.1 just like the normal localhost
  MAIN_DOMAIN = 'www.localhost'
  MAIN_PORT = '3000'
  MAIN_DOMAIN_LEVEL = MAIN_DOMAIN.split('.').size - 1
  MAIN_DOMAIN_WITH_PORT = [MAIN_DOMAIN,MAIN_PORT].join(':')

  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  config.allow_concurrency = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true    #set to false to view custom errors pages in dev mode
  config.action_controller.perform_caching = true

  # ActionMailer Config
  config.action_mailer.default_url_options = { :host => MAIN_DOMAIN_WITH_PORT }
  # A dummy setup for development - no deliveries, but logged
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Do not compress assets
  config.assets.compress = false
  
  config.assets.quiet = true

  # Expands the lines which load the assets
  config.assets.debug = false

  config.eager_load = false

  Delayed::Worker.delay_jobs = true

  config.debug_exception_response_format = :api
end
