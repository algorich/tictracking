source 'https://rubygems.org'

ruby '2.0.0'


gem 'rails', '3.2.13'
gem 'pg'
gem 'jquery-rails'
gem 'devise', '2.2.4'
gem 'cancan', '~> 1.6.10'
gem 'simple_form', '~> 2.1.0'
gem 'twitter-bootstrap-rails', '~> 2.2.7'
gem 'select2-rails', '~> 3.4.2'
gem 'bootstrap-datetimepicker-rails', '~> 0.0.11'

group :assets do
  gem 'therubyracer', :platforms => :ruby
  gem 'uglifier', '>= 1.0.3'
end

group :test, :development do
  gem 'pry', '~> 0.9.12'
  gem 'pry-rails', '~> 0.3.0'
  gem 'rspec-rails', '~> 2.13.2'
  gem 'factory_girl_rails', '~> 4.2.1'
end

group :test do
  gem 'timecop', '~> 0.6.1'
  gem 'capybara', '~> 2.1.0'
  gem 'poltergeist', '~> 1.3.0'
  gem 'launchy', '~> 2.3.0'
  gem 'valid_attribute', '~> 1.3.1'
  gem 'shoulda', '~> 3.5.0'
  gem 'simplecov', '~> 0.7.1', require: false
end

group :development do
  gem 'better_errors' # replaces the standard Rails error page with a much better and more useful error page
  gem 'binding_of_caller' # add advanced feature to better_errors
  gem 'xray-rails'
end