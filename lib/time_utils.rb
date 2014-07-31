class TimeUtils
  # Finds number and am/pm info in command, converts to military time
  def self.parse(command)
    hour = /(\d+)/.match(command)[0]
    period = /((a|A)|(p|P))(m|M)/.match(command)[0] # match am/pm
    
    if period.downcase == 'am'
        time = hour + '00'
    else
        time = (12 + hour.to_i).to_s + '00'
    end
    return time.to_i
  end
end
