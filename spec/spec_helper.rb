# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment.rb",  __FILE__)
include ActiveScraper
require "rails/all"
require 'rspec/rails'


require 'pry'
require 'database_cleaner'
require 'rspec/autorun'
require 'webmock/rspec'
require 'httparty'
require 'vcr'

VCR.configure do |c|
   c.hook_into :webmock
  c.cassette_library_dir = 'fixtures/vcr_cassettes'
end


#require 'capybara/rails'
#require 'capybara/rspec'

DatabaseCleaner.strategy = :truncation

ENGINE_RAILS_ROOT=File.join(File.dirname(__FILE__), '../')
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(ENGINE_RAILS_ROOT, "spec/support/**/*.rb")].each {|f| require f }



RSpec.configure do |config|
#  config.include FactoryGirl::Syntax::Methods


  config.filter_run_excluding skip: true 
  config.run_all_when_everything_filtered = true
  config.filter_run :focus => true

  config.mock_with :rspec
  config.order = "random"
  # Use color in STDOUT
  config.color_enabled = true
  # Use the specified formatter
  config.formatter = :documentation # :progress, :html, :textmate
  # Use color not only in STDOUT but also in pagers and files
  config.tty = true
#  config.use_transactional_fixtures = true


  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
