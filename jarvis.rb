require_relative './lib/listener.rb'
require_relative './lib/calendar.rb'
require 'zulip'

class Jarvis
    config = {greeting: 'Jarvis is online.',
              stream: 'test-bot'}


    cal = Calendar.new
    zulip = Zulip::Client.new do |config|
        config.email_address = ENV.fetch( 'ZULIP_JARVIS_EMAIL' )
        config.api_key = ENV.fetch( 'ZULIP_JARVIS_API_KEY' )
    end
    stream = config.fetch(:stream)

    zulip.subscribe(stream)
    zulip.send_message('jarvis-testing', 'Hello.', 'test-bot')
    
    zulip.stream_messages do |message|
        if message.content.match /\@jarvis/
            begin
                parsed_message = Listener.listen(message.content, message.sender_full_name)
                
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
            zulip.send_message(message.subject, response, stream)
        end
    end
        
end
