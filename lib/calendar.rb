# insert event into calendar, at given time, in given room
# default to one hour
# use organizer name

require 'date'
require 'jwt'
require 'net/http'
require 'pry'

class Authentication
    JARVIS_SECRET_PATH = "../Jarvis-8746cc8b4449.json"
    JARVIS_GOOGLE_SCOPE = "https://www.googleapis.com/auth/calendar"
    GOOGLE_AUD_URL = "https://accounts.google.com/o/oauth2/token"
    GOOGLE_GRANT_TYPE = "urn:ietf:params:oauth:grant-type:jwt-bearer"
    # create and sign jwt
    # use jwt to get authentication token -> returns a auth token
    def initialize # hardcoded file path for now
        # TODO: there is obviously a better way to do this
        binding.pry
        uri = URI(GOOGLE_AUD_URL)
        grant_type = URI.encode_www_form_component(GOOGLE_GRANT_TYPE)
        token_dictionary = Net::HTTP.post_form(uri, {"grant_type" => grant_type,
                                                      "assertion" => make_jwt})
        token = token_dictionary['access_token']
        puts token_dictionary
        token
    end
    
    def make_jwt
        secret_json = File.read(File.join(File.expand_path(File.dirname(__FILE__)), JARVIS_SECRET_PATH))
        secret_dictionary = JSON.parse(secret_json)
        iss = secret_dictionary['client_email']
        iat = DateTime.now.to_time.strftime('%s').to_i
        exp = iat + 60 * 60
        jwt_claim = {
           iss: iss,
           scope: JARVIS_GOOGLE_SCOPE,
           aud: GOOGLE_AUD_URL,
           exp: exp,
           iat: iat
        }
        JWT.encode(jwt_claim, secret_dictionary['private_key'])
    end
end

class Calendar
    # initialize with auth token
end