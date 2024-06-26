# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 7.0.8', '>= 7.0.8.1'

# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '~> 4.3.9'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem 'spring'

  # Used to pretty prints Ruby objects in full color exposing their internal structure with proper indentation
  gem 'awesome_print'

  # Adds step-by-step debugging and stack navigation capabilities to pry using byebug.
  gem 'pry-byebug'

  # Brakeman is a static analysis tool which checks Ruby on Rails applications for security vulnerabilities.
  gem 'brakeman'

  # Used to check code quality.
  gem 'rubycritic'

  # RuboCop is a Ruby static code analyzer (a.k.a. linter) and code formatter.
  gem 'rubocop'

  # Performance optimization analysis for your projects, as an extension to RuboCop.
  gem 'rubocop-performance'

  # A RuboCop extension focused on enforcing Rails best practices and coding conventions.
  gem 'rubocop-rails'

  gem 'capistrano', require: false
  gem 'capistrano3-puma', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-rbenv', require: false
end

# Devise gem
gem 'devise'

# Doorkeeper gem
gem 'doorkeeper'

# User Role Management
gem 'rolify'

# Amazon SDK S3
gem 'aws-sdk-s3'

# Pundit
gem 'pundit'

# ExcelSheet Handler
gem 'roo', '~> 2.8'

# Pagination Gem
gem 'pagy'

# Use to create the excel file
gem 'axlsx', '3.0.0.pre'
