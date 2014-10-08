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
  access_info = "Jarvis can post to the calendars #{cal.calendars}"
  zulip.send_message('jarvis-testing', access_info, 'test-bot')
  calendar_info = "Jarvis is configured to post to the calendar #{cal.id}"
  zulip.send_message('jarvis-testing', calendar_info, 'test-bot')

  unless cal.calendars.map { |c| c['id'] }.include?(cal.id) 
    jarvis_username = ENV['GOOGLE_JARVIS_CLIENT_EMAIL']
    config_help = <<-eos
      Jarvis cannot post to the desired calendar (#{cal.id})! 
      [Share](https://support.google.com/calendar/answer/37082) 
      your calendar with Jarvis (his google username is #{jarvis_username}),
      and then set the environment variable `JARVIS_CALENDAR_ID` to 
      your google calendar address on 
      [Heroku](https://dashboard-next.heroku.com/apps/jarvis-hs/settings).
    eos
    zulip.send_message('jarvis-testing', config_help, 'test-bot')
  end
  
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
      rescue Listener::FailedToParse, Calendar::CouldNotAddEvent => e
        response = e.message
      end

      zulip.send_message(message.subject, response, stream)
    end
  end
      
end
