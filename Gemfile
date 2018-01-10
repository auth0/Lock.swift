source 'https://rubygems.org'

gem 'fastlane', '2.60'
gem 'jwt', '~> 1.5'

group :development do
  gem 'cocoapods', '~> 1.0'
end

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
