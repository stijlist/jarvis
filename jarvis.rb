require_relative './lib/listener.rb'
require_relative './lib/calendar.rb'
require 'zulip'

class Jarvis
  config = {greeting: 'Jarvis is online.',
            streams: File.read('./streams_filtered').lines.map(&:chomp)}

  cal = Calendar.new
  zulip = Zulip::Client.new do |config|
    config.email_address = ENV.fetch( 'ZULIP_JARVIS_EMAIL' )
    config.api_key = ENV.fetch( 'ZULIP_JARVIS_API_KEY' )
  end

  # config.fetch(:streams).each do |stream|
  #   zulip.subscribe(stream)
  # end

  zulip.send_message('jarvis-testing', config[:greeting], 'test-bot')
  
  zulip.stream_messages do |message|
    stream = message.stream
    if message.content.match(/(\@jarvis|\@\*\*jarvis\*\*)/) and message.sender_email != ENV.fetch( 'ZULIP_JARVIS_EMAIL' )
      zulip.send_message('calendars', cal.calendars.to_s, stream) and next if message.content.match(/active calendars/) 
      begin
        parsed_message = Listener.listen(message.content, message.sender_full_name)
        
        request_start = parsed_message[:date]
        request_end = request_start + Rational(1, 24) # add one hour
        room = parsed_message[:room].capitalize
        description = parsed_message[:description]
     
        bookable = cal.bookable_for?(request_start, request_end, room)
        if bookable
          event = cal.add(request_start, request_end, room, description)
          link = event['htmlLink']
          response = "Booked #{room} on #{request_start.strftime("%A, %B %d from %H:%M")} to #{request_end.strftime("%H:%M")} for #{description}: [#{link}](#{link})"
        else
          response = "#{room} is busy #{request_start.strftime("at %H:%M on %A, %B %d")}."
        end
      rescue Listener::FailedToParse => e
        response = e.message
      end

      zulip.send_message(message.subject, response, stream)
    end
  end
      
end
