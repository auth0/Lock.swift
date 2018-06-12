source 'https://rubygems.org'

gem 'fastlane'
gem 'jwt', '~> 1.5'
gem 'dotenv', '~> 2.4'

group :development do
  gem 'cocoapods', '~> 1.0'
end

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
