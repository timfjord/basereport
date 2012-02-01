require "sinatra"
require "slim"
require "json"

require "./report"

set :public_folder, File.dirname(__FILE__) + "/public"

get "/" do
  current_date = Time.new
  
  @m = (params["m"] || current_date.month).to_i - 1
  @y = (params["y"] || current_date.year).to_i
  
  slim :index
end

get "/feed" do
  return "Wrong params" if params["start"].nil? || params["end"].nil?
  
  content_type :json
  
  report = Report.new
  
  report.feed(params).to_json
end

get "/total" do
  return "Wrong params" if params["month"].nil? || params["year"].nil?
  
  content_type :json
  
  report = Report.new
  
  report.total(params).to_json
end