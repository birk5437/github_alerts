require 'date'

class Logger
  def self.log(text, include_timestamp=true)
    if include_timestamp
      puts "#{DateTime.now.to_s} - #{text}"
    else
      puts text
    end
  end
end
