ENV["RAILS_ENV"] ||= 'test'

require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

require 'rspec/rails'
require 'capybara/rails'
require 'database_cleaner'


Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|

  # factorygirl
  config.include FactoryGirl::Syntax::Methods

  # devise
  config.include Devise::TestHelpers, type: :controller
  config.before :each, type: :controller do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  # database_cleaner
  config.before :suite do
    # DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  config.around :each do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  # helpers
  config.include ControllerHelpers::Session, type: :controller
  config.include FeatureHelpers::Session, type: :feature

  # automatically mix in different behaviours to your tests
  # based on their file location
  config.infer_spec_type_from_file_location!
end
