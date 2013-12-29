$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_scraper/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_scraper"
  s.version     = ActiveScraper::VERSION
  s.authors     = ["Dan Nguyen"]
  s.email       = ["dansonguyen@gmail.com"]
  s.homepage    = "http://github.com/dannguyen/active_scraper"
  s.summary     = "A Rails Engine using ActiveRecord to cache results of HTTP scrapes"
  s.description = "A Rails Engine using ActiveRecord to cache results of HTTP scrapes"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_development_dependency "rails", "~> 4.1.0.beta1"
  s.add_dependency "httparty"
  s.add_dependency "nokogiri"
  s.add_dependency 'addressable'
  s.add_development_dependency 'minitest' # just because it conflicts with rspec right now
  s.add_development_dependency "database_cleaner", '=1.0.1'
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "webmock"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency "vcr"  
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec-rails"

end


