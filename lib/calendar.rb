# insert event into calendar, at given time, in given room
# default to one hour
# use organizer name

require 'date'
require 'json'
require 'jwt'
require 'net/http'
require 'digest/sha2'
require 'openssl'

class Authentication
    JARVIS_SECRET_PATH = "../Jarvis-8746cc8b4449.json"
    JARVIS_GOOGLE_SCOPE = "https://www.googleapis.com/auth/calendar"
    GOOGLE_AUD_URL = "https://accounts.google.com/o/oauth2/token"
    GOOGLE_GRANT_TYPE = "urn:ietf:params:oauth:grant-type:jwt-bearer"
    
    attr_accessor :token, :response_dict

    def initialize
        uri = URI(GOOGLE_AUD_URL)
        grant_type = GOOGLE_GRANT_TYPE
        response_body = Net::HTTP.post_form(uri, {"grant_type" => grant_type,
                                                      "assertion" => make_jwt}).body
        @response_dict = JSON.parse(response_body)
        @token = @response_dict["access_token"]
    end
    
    def make_jwt
        secret_json = File.read(File.join(File.expand_path(File.dirname(__FILE__)), JARVIS_SECRET_PATH))
        secret_dictionary = JSON.parse(secret_json)
        iss = secret_dictionary['client_email']
        iat = DateTime.now.to_time.strftime('%s').to_i
        exp = iat + 60 * 60 # expires 1 hour (60*60) from now
        jwt_claim = {
           "iss" => iss,
           "scope" => JARVIS_GOOGLE_SCOPE,
           "aud" => GOOGLE_AUD_URL,
           "exp" => exp,
           "iat" => iat
        }

        # ssl_key = OpenSSL::PKey::RSA.new secret_dictionary['private_key']
        # JWT.encode(jwt_claim, ssl_key, "RS256")
        JWT.encode(jwt_claim, secret_dictionary['private_key'], "RS256")
    end
end

class Calendar
    JARVIS_TEST_CALENDAR_ID = "27oim6lpetk763ipds6au4cmgc@group.calendar.google.com"
    API_BASE = "https://www.googleapis.com/calendar/v3/calendars/#{JARVIS_TEST_CALENDAR_ID}"
        # todo: factor out id
    
    attr_accessor :id
    
    def initialize(id = JARVIS_TEST_CALENDAR_ID) 
        @auth_token = Authentication.new.token
        @id = id
    end
    
    def events
        #use nhttp to make get request to go
        events_url = API_BASE + "/events?access_token=#{@auth_token}"
        response = Net::HTTP.get(URI(events_url))
        JSON.parse(response)["items"]
        # wrap in class pulling out all google stuff
            # look at items, make sure it's there!
            # ANOTHER class handles the internals of items
    end
end
