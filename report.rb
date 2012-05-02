require "basecamp"

class Report
  def initialize
    file = "config.yaml"
    @config = YAML::load(File.open(file))
    
    abort('Wrong params') if !@config.is_a?(Hash) || @config["domain"].nil? || @config["username"].nil? 
  end
  
  def connect!
    Basecamp.establish_connection!(
      @config["domain"], 
      @config["username"], 
      @config["password"] || 'X', 
      @config["use_ssl"] || true
    )
  end
  
  def report(from, to)
    Basecamp::TimeEntry.report({
      "filter_project_id" => @config['project'],
      "from" => from,
      "to" => to
    })
  end
  
  def feed(params)
    connect!
    
    from = Time.at(params["start"].to_i).strftime('%Y%m%d')
    to = Time.at(params["end"].to_i).strftime('%Y%m%d')

    res = {}
    report(from, to).each do |time_entry|
      key = "%s-%s" % [time_entry.person_id.to_s, time_entry.date.to_time.to_i.to_s]
      
      if res.has_key? key
        res[key]["hours"] += time_entry.hours
        res[key]["title"] = "%s - %s" % [
          time_entry.person_name, 
          self.class.format_hours(res[key]["hours"])
        ]
      else
        res[key] = {
          "title" => "%s - %s" % [time_entry.person_name, 
            self.class.format_hours(time_entry.hours)],
          "hours" => time_entry.hours,
          "allDay" => true,
          "start" => time_entry.date,
          "end" => time_entry.date,
          "className" => 'timeEntryFor' + time_entry.person_name.gsub(/\s+/, '')
        }
      end
    end
    
    res.values
  end
  
  def total(params)
    connect!
    
    from = Date.civil(params["year"].to_i, params["month"].to_i, 1).strftime('%Y%m%d')
    to = Date.civil(params["year"].to_i, params["month"].to_i, -1).strftime('%Y%m%d')
    
    res = {}
    total = 0
    report(from, to).each do |time_entry|
      total += time_entry.hours
      if res.has_key? time_entry.person_id
        res[time_entry.person_id]['raw_hours'] += time_entry.hours
        res[time_entry.person_id]['hours'] = self.class.format_hours(res[time_entry.person_id]['raw_hours'])
      else
        res[time_entry.person_id] = {
          "name" => time_entry.person_name,
          "hours" => self.class.format_hours(time_entry.hours),
          "raw_hours" => time_entry.hours,
          "className" => 'timeEntryFor' + time_entry.person_name.gsub(/\s+/, '')
        }
      end
    end
    
    {"summary" => res, "total" => self.class.format_hours(total)}
  end
  
  class << self
    def format_hours(hours)
      h = hours.to_i
      m = ((hours - h) * 60).to_i
      
      res = "%dh" % [h]
      res += " %dm" % [m] if m > 0
      
      res
    end
  end
end