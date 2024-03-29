require 'rubygems'
require 'bundler'

Bundler.require

require './basereport'
 
root_dir = File.dirname(__FILE__)
 
set :environment, (ENV['RACK_ENV'] || "development").to_sym
set :root,        root_dir
set :app_file,    File.join(root_dir, 'basereport.rb')
disable :run
 
run Sinatra::Application