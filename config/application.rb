require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

module RailsOSRM
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(#{config.root}/lib)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = :da

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :password_confirmation]

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    # config.active_record.whitelist_attributes = true

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    #avoid loading environment during asset precompilation. required on heroku
    config.assets.initialize_on_precompile = false

    #3.2 way of catching exceptions
    config.exceptions_app = self.routes


    #modify the way rails styles fields with errors in forms.
    #by default rails wraps fields with erros in <div class="field_with_errors">.
    #this is a problem if the <div> is inside an inline element like <p>.
    #<label> items are wrapped by <span class="field_with_errors">
    #other tags like input and text-areas are not wrapped, since this would interfere with the javascript that shows characters left
    ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
      #include ActionView::Helpers::RawOutputHelper
      if html_tag =~ /<(label)/
        %(<span class="field_with_errors">#{html_tag}</span>).html_safe   #wrap label tags with spans
      else
        html_tag    #don't wrap other tags (line input or text-area)
      end
    end

    #configure acts_as_taggable
    ActsAsTaggableOn.remove_unused_tags = true  #remove unused tag objects after removing taggings
    ActsAsTaggableOn.force_lowercase = true     #save all tags as lowercase

    #rails-timeago gem settings
    Rails::Timeago.default_options :limit => proc { 1.month.ago }
    #Rails::Timeago.locales = [:en, :da]
  end
end

APP_VERSION = 'Alpha'
