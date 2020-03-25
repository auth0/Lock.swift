source 'https://rubygems.org'

gem 'fastlane', '>= 2.127.2'
gem 'jwt', '~> 2.1'
gem 'dotenv', '~> 2.4'
gem "cocoapods", ">= 1.8.4"

plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval(File.read(plugins_path), binding) if File.exist?(plugins_path)
