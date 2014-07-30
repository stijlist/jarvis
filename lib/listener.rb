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
