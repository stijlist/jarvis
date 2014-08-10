require 'chronic'
require 'pry'
require 'date'

class Listener

    COMMANDS = ["reserve"] # make set?
    ROOMS = ["babbage", "hopper", "church", "lovelace", "turing"]
    
# Parse event scheduling information from a Zulip message, raising appropriate message if not-parseable
# 
# command       - string containing text of message received from Zulip
# sender        - string containing sender of message
#
# Returns a hash containing information
    def self.listen(command, sender)
        parsed_input = command.split
    
        # Get description
        desc_index = parsed_input.index("for") 
        if desc_index.nil?
            description = "Booked by Jarvis for #{sender}"
        else
            description = parsed_input[(desc_index + 1)..-1].join(' ')
        end

        # Now downcase everything
        parsed_input = parsed_input.map {|word| word.downcase}

        parsed_command = (COMMANDS & parsed_input)[0].to_sym # & -- set intersection
        parsed_room = (ROOMS & parsed_input)[0]
        parsed_time = Chronic.parse(command)

        raise FailedToParse, "It appears that your query is underspecified. Try adding a valid room." unless parsed_room
        raise FailedToParse, "It appears that your query is underspecified. Perhaps you should use a more descriptive time format.\nFormats I understand: \n - today at 4pm \n - thurs at 2 \n - tomorrow at 16.25 \n - 2014-08-11 18:00:00 -0400" unless parsed_time

        parsed_date = DateTime.parse(parsed_time.to_s)
        {command: parsed_command, 
         room: parsed_room,
         date: parsed_date,
         description: description}
    end
end

class FailedToParse < StandardError
end 
