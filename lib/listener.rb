class Listener

  COMMANDS = ["reserve"] # make set?
  ROOMS = ["Hopper"]
  DAYS = ["Tuesday"]
  

  def self.listen(command)
    parsed_input = command.split
    
    puts parsed_input
    
    # & -- set intersection
    parsed_command = (COMMANDS & parsed_input)[0].to_sym
    parsed_room = (ROOMS & parsed_input)[0]
    parsed_day = (DAYS & parsed_input)[0]
    
    {command: parsed_command, 
     room: parsed_room,
     day: parsed_day}
  end
end

class JarvisTime
  def self.parse(command)
    hour = /(\d+)/.match(command)[0]
    period = /((a|A)|(p|P))(m|M)/.match(command)[0]
    
    if period.downcase == 'am'
        time = hour + '00'
    else
        time = (12 + hour.to_i).to_s + '00'
    end
    return time.to_i
  end
end
