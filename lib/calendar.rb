# insert event into calendar, at given time, in given room
# default to one hour
# use organizer name

require 'date'
require 'json'
require 'jwt'
require 'net/http'
require 'digest/sha2'
require 'openssl'

class Calendar
  class CouldNotAddEvent < StandardError; end
  API_BASE = "https://www.googleapis.com/calendar/v3/calendars/#{ENV.fetch('GOOGLE_JARVIS_CALENDAR_ID')}"
  
  attr_reader :id

  def initialize 
    @auth_token = Authenticator.token
    @id = ENV.fetch('GOOGLE_JARVIS_CALENDAR_ID')
  end

  # Gets a list of events scheduled on a given calendar
  #
  # Returns a list of hashes, each representing one event 
  def events
    events_url = API_BASE + "/events"
    response = get_api_request(events_url)
    response['items']
  end

  def calendars
    calendars_url = "https://www.googleapis.com/calendar/v3/users/me/calendarList"
    response = get_api_request(calendars_url)
    response.fetch('items')
  end

  def calendars_summary
    calendars.map do |item|
      "#{item.fetch('summary')} (#{item.fetch('id')}), accessLevel: #{item.fetch('accessRole')}" 
    end.join("\n")
  end

  # Add a calendar event
  # 
  # start_time    - Ruby DateTime object, must be before end_time and have its time
  #                 zone offset correctly set (e.g. start_time.new_offset("-04:00"))
  # end_time      - Ruby DateTime object, must be after start_time and have its time
  #                 zone offset correctly set (e.g. end_time.new_offset("-04:00"))
  # room          - string, will be set as event location
  # description   - string, will be set as event summary (or 'title' to us normal people)
  #
  # Returns the JSON body of the response
  def add(start_time, end_time, room, description)
    params = {
      end: {
        dateTime: end_time.rfc3339
      },
      start: {
        dateTime: start_time.rfc3339
      },
      location: room,
      summary: description
    }.to_json

    response = post_api_request("/events", nil, params)
    if response['error']
      raise CouldNotAddEvent, response['error']
    end

    response
  end

  # Check whether a proposed event overlaps temporally/spatially with any already scheduled events
  # 
  # request_start - Ruby DateTime object, must be before request_end and have its time
  #                 zone offset correctly set (e.g. request_start.new_offset("-04:00"))
  # request_end   - Ruby DateTime object, must be after request_start and have its time
  #                 zone offset correctly set (e.g. request_end.new_offset("-04:00"))
  # room          - string, will be used to find overlapping locations
  #
  # Returns true if proposed time/room combination can be scheduled, and
  #         false if it overlaps with already scheduled events
  def bookable_for?(request_start, request_end, request_room)

      self.events.each do |event|

        event_can_be_checked_for_conflicts = 
          event['start'] and event['start']['dateTime'] and event['end'] and event['end']['dateTime'] and event['location']
        

        if event_can_be_checked_for_conflicts
          begin
            event_start = DateTime.rfc3339(event['start']['dateTime'])
            event_end = DateTime.rfc3339(event['end']['dateTime'])
          rescue ArgumentError
            # we got an non-rfc3339 datetime and can't make a comparison
            next 
          end
          event_room = event['location']
          
          if event_room == request_room
            
            # not (end1 < start2 or end2 < start1) --- (http://c2.com/cgi/wiki?TestIfDateRangesOverlap)
            # http://makandracards.com/makandra/984-test-if-two-date-ranges-overlap-in-ruby-or-rails
            if ((request_start - event_end) * (event_start - request_end)) >= 0
              return false
            end
          end    
        end
      end

      return true
  end

  def diagnostics
    access_info = "Jarvis can post to the calendars #{calendars_summary}"
    calendar_info = "Jarvis is configured to post to the calendar #{id}"

    if has_access_to_desired_calendar?(id)
      diagnostics = access_info + calendar_info
    else
      warning = "`WARNING:`" +
        "Jarvis cannot post to the desired calendar (#{id})! " +
        "[Share](https://support.google.com/calendar/answer/37082) " +     
        "your calendar with Jarvis (his google username is #{ENV['GOOGLE_JARVIS_CLIENT_EMAIL']}), " +
        "and then set the environment variable `JARVIS_CALENDAR_ID` to " +
        "your google calendar address on [Heroku]" +
        "(https://dashboard-next.heroku.com/apps/jarvis-hs/settings)."
      diagnostics = [access_info, calendar_info, warning].join('\n')
    end

    diagnostics
  end

private

  def has_access_to_desired_calendar?(calendar_id)
    self.calendars.map { |c| c['id'] }.include?(calendar_id) 
  end

  def get_api_request(url)
    response = Net::HTTP.get(URI(append_access_token(url)))
    JSON.parse(response)
  end

  def append_access_token(url)
    url += "?access_token=#{@auth_token}"
  end

  # Sends a post request containing either query parameters or a JSON request body
  # 
  # relative_url  - string indicating the URL relative to API_BASE
  # form_data     - hash containing query parameters
  #                 if nil, method assumes that request_body is present
  # request_body  - JSON string containing request body
  #
  # Returns Net::HTTP response object
  def post_api_request(relative_url, form_data, request_body)
    uri = URI(API_BASE + relative_url)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(form_data) if form_data
    if request_body
      req.body = request_body
      req['Content-Type'] = 'application/json'
    end
    req['Authorization'] = "Bearer #{@auth_token}"
    res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(req)
    end
    JSON.parse(res.body)
  end
end

class Authenticator
  JARVIS_GOOGLE_SCOPE = "https://www.googleapis.com/auth/calendar"
  GOOGLE_AUD_URL = "https://accounts.google.com/o/oauth2/token"
  GOOGLE_GRANT_TYPE = "urn:ietf:params:oauth:grant-type:jwt-bearer"
  
  def self.fetch_token
    uri = URI(GOOGLE_AUD_URL)
    grant_type = GOOGLE_GRANT_TYPE
    response_body = Net::HTTP.post_form(uri, {grant_type: grant_type,
                                               assertion: make_jwt}).body
    response_dict = JSON.parse(response_body)
    response_dict["access_token"]
  end

  def self.token
    @@token ||= fetch_token
    @@token
  end

  # Creates a JSON web token according to Google API specifications
  #
  # Returns the jwt   
  def self.make_jwt
    iss = ENV.fetch('GOOGLE_JARVIS_CLIENT_EMAIL') 
    iat = DateTime.now.to_time.strftime('%s').to_i
    exp = iat + 60 * 60 # expires 1 hour (60*60) from now
    jwt_claim = {
      "iss" => iss,
      "scope" => JARVIS_GOOGLE_SCOPE,
      "aud" => GOOGLE_AUD_URL,
      "exp" => exp,
      "iat" => iat
    }

    ssl_key = OpenSSL::PKey::RSA.new ENV.fetch('GOOGLE_JARVIS_PRIVATE_KEY') 
    JWT.encode(jwt_claim, ssl_key, "RS256")
  end
end
