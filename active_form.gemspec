$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "active_form/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "active_form"
  s.version     = ActiveForm::VERSION
  s.authors     = ["Petros Markou"]
  s.email       = ["markoupetr@gmail.com"]
  s.homepage    = "https://github.com/m-Peter/activeform"
  s.summary     = "Create nested forms with ease."
  s.description = "An alternative layer to accepts_nested_attributes_for by using Form Models."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency('rake', '~> 10.3.2')
end
