# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard 'bundler' do
  watch('Gemfile')
  # Uncomment next line if Gemfile contain `gemspec' command
  # watch(/^.+\.gemspec/)
end

guard 'livereload' do
  watch(%r{app/views/.+\.(erb|haml|slim)})
  watch(%r{app/helpers/.+\.rb})
  watch(%r{public/.+\.(css|js|html)})
  watch(%r{config/locales/.+\.yml})
  # Rails Assets Pipeline
  watch(%r{(app|vendor)/assets/\w+/(.+\.(css|js|html|scss)).*})  { |m| "/assets/#{m[2]}" }
end

guard 'rails', :port => 3002, :server => 'thin' do
  watch('Gemfile.lock')
  watch(%r{^(config)/.*})
end

### Guard::Sidekiq
#  available options:
#  - :verbose
#  - :queue (defaults to "default")
#  - :concurrency (defaults to 1)
#  - :timeout
#  - :environment (corresponds to RAILS_ENV for the Sidekiq worker)
guard 'sidekiq', :environment => 'development' do
  watch(%r{^app/workers/(.+)\.rb$})
end
