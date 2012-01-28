require "basecamp"
require "psych"

class Report
  def initialize
    file = "config.yaml"
    @config = Psych.load_file(file)
  end
  
  def connect!
    Basecamp.establish_connection!(
      @config['domain'], 
      @config['username'], 
      @config['password'], 
      @config['use_ssl'], 
    )
  end
  
  def report(from, to)
    Basecamp::TimeEntry.report({
      'filter_project_id' => @config['project'],
      'from' => from,
      'to' => to
    })
  end
  
  def feed(params)
    connect!
    
    from = Time.at(params['start'].to_i).strftime('%Y%m%d')
    to = Time.at(params['end'].to_i).strftime('%Y%m%d')

    res = []
    report(from, to).each do |time_entry|
      item = {
        :title => "%s (%s hours)" % [time_entry.person_name, time_entry.hours.to_i],
        :allDay => true,
        :start => time_entry.date.to_time.to_i,
        :end => time_entry.date.to_time.to_i,
        :className => 'timeEntryFor' + time_entry.person_name.gsub(/\s+/, '')
      }

      res << item 
    end
    
    res
  end
  
  def total(params)
    connect!
    
    from = Date.civil(params['year'].to_i, params['month'].to_i, 1).strftime('%Y%m%d')
    to = Date.civil(params['year'].to_i, params['month'].to_i, -1).strftime('%Y%m%d')
    
    res = {}
    report(from, to).each do |time_entry|
      if res.has_key? time_entry.person_id
        res[time_entry.person_id]['hours'] += time_entry.hours.to_i
      else
        res[time_entry.person_id] = {
          'name' => time_entry.person_name,
          'hours' => time_entry.hours.to_i,
          'className' => 'timeEntryFor' + time_entry.person_name.gsub(/\s+/, '')
        }
      end
    end
    
    res
  end
end