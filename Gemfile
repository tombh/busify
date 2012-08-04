source 'https://rubygems.org'

gem 'rails', '3.2.3'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mongoid'
gem 'bson_ext'
gem 'geocoder'
gem 'atco', :path => '/home/tombh/Workspace/atco'

gem 'sidekiq', :path => '/home/tombh/Workspace/sidekiq'
gem 'slim'
# if you require 'sinatra' you get the DSL extended to Object
gem 'sinatra', :require => nil

gem 'websocket-rails'

gem "rails-backbone", :git => 'git://github.com/teleological/backbone-rails.git'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platform => :ruby

  gem 'uglifier', '>= 1.0.3'
end


group :development do
  gem 'libnotify'
  gem 'guard'
  gem 'guard-rails'
  gem 'guard-bundler'
  gem 'guard-livereload'
  gem 'guard-sidekiq'
  gem 'rails-footnotes'
  gem "capistrano"
end