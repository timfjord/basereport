require "sinatra"
require "slim"
require "json"

require "./report"

set :public_folder, File.dirname(__FILE__) + '/public'

get "/" do
  slim :index
end

get "/feed" do
  abort("Wrong params") if params['start'].empty? || params['end'].empty?
  
  content_type :json
  
  report = Report.new
  
  report.feed(params).to_json
end

get "/total" do
  abort("Wrong params") if params['month'].empty? || params['year'].empty?
  
  content_type :json
  
  report = Report.new
  
  report.total(params).to_json
end