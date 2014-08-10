require 'net/http'
require 'json'

module Zulip
  Response = Struct.new(:message, :success?, :id)
  Message  = Struct.new(:content, :user, :id)

  class Client
    attr_accessor :streams, :email, :api_key
    def initialize(email, api_key)
      @email = email
      @api_key = api_key
    end

    def subscribe_to_stream!(stream_name)
      @streams << Zulip::Stream.new(self, stream_name)
    end

    def send_message!(stream, text, subject)
      uri = URI('https://api.zulip.com/v1/messages')
      req = Net::HTTP::Post.new(uri)
      req.basic_auth(@email, @api_key)
      req.set_form_data({type: 'stream', to: 'test-bot', 
                         content: text, subject: subject})
      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      result = JSON.parse(response.body)
      pp result.tap {|r| r.delete 'presences'}
      Response.new(result['msg'], (result['result'] == 'success'), result['id']) 
    end

  end

  class Stream
    def initialize(client, stream_name)
      @client_email = client.email
      @client_api_key = client.api_key
      uri = URI('https://api.zulip.com/v1/register')
      req = Net::HTTP.post.new(uri)
      req.basic_auth(@client_email, @client_api_key)
      res = Net::HTTP.start(uri.hostname, uri.port) do |http|
        http.request(req)
      end
      data = JSON.parse(res.body)
      @queue_id, @last_event_id= [ data['queue_id'], data['last_event_id'] ]
      @messages = []
    end

    def messages
      req = Net::HTTP.get.new
      req.basic_auth(@client_email, @client_api_key)
      @messages << []
    end
  end
end
