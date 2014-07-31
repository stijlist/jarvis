require_relative './time_utils.rb'

class Listener

  COMMANDS = ["reserve"] # make set?
  ROOMS = ["Hopper"]
  DAYS = ["Tuesday"]

  def self.listen(command)
    parsed_input = command.split
    
    # & -- set intersection
    parsed_command = (COMMANDS & parsed_input)[0].to_sym
    parsed_room = (ROOMS & parsed_input)[0]
    parsed_day = (DAYS & parsed_input)[0]
    parsed_time = TimeUtils.parse(command)
    
    {command: parsed_command, 
     room: parsed_room,
     day: parsed_day,
     time: parsed_time}
  end
end
