ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../../Gemfile', __dir__)
require 'bundler/setup' if File.exist?(ENV['BUNDLE_GEMFILE'])
require 'logger' # Ruby 3.1+ no longer auto-loads Logger
$LOAD_PATH.unshift File.expand_path('../../../lib', __dir__)
