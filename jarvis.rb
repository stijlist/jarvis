require_relative './lib/listener.rb'
require_relative './lib/calendar.rb'

class Jarvis
    cal = Calendar.new
    # loop!!!
    # get queue of more events from zulip
        # loop.do 
        # request = queue.pop
        # user = request.sender
        sender = "me"
        puts "Send a request to Jarvis: "
        message = gets.chomp
        
        begin
            parsed_message = Listener.listen(message, sender)
            
            request_start = parsed_message[:date]
            request_end = request_start + Rational(1, 24) # add one hour
            room = parsed_message[:room].capitalize
            description = parsed_message[:description]
         
            bookable = cal.bookable_for?(request_start, request_end, room)
            if bookable
                cal.add(request_start, request_end, room, description)
                response = "Booked #{room} on #{request_start.strftime("%A, %B %d from %H:%M")} to #{request_end.strftime("%H:%M")} for #{description}."
            else
                response = "#{room} is busy #{request_start.strftime("at %H:%M on %A, %B %d")}."
            end
        rescue FailedToParse => e
            response = e.message
        end
        
        puts response
        # Zulip.send_response(response)
end
