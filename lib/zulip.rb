require 'net/http'
require 'json'

module Zulip
  Response = Struct.new(:message, :success?, :id)
  Message  = Struct.new(:content, :user, :id)
  Stream   = Struct.new(:queue_id, :last_event_id, :name)

  class Client
    attr_accessor :streams, :email, :api_key
    def initialize(email, api_key)
      @email = email
      @api_key = api_key
      @streams = []
    end

    def send_message!(stream, text, subject)
      uri = URI('https://api.zulip.com/v1/messages')
      req = Net::HTTP::Post.new(uri)
      req.basic_auth(@email, @api_key)
      req.set_form_data({type: 'stream', to: 'test-bot', 
                         content: text, subject: subject})
      resp = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      result = JSON.parse(resp.body)
      Response.new(result['msg'], (result['result'] == 'success'), result['id']) 
    end

    def register_for_stream(stream_name)
      # NOTE: need to hit https://api.zulip.com/v1/users/me/subscribe
      # NOTE: the subscribe endpoint is undocumented
      # TODO: registering a queue for messages doesn't work without the above
      uri = URI('https://api.zulip.com/v1/register')
      req = Net::HTTP::Post.new(uri)
      req.basic_auth(@email, @api_key)
      req.set_form_data(event_types: ['message'].to_json)
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      resp = JSON.parse(res.body)
      result, q_id, last = resp.values_at('result', 'queue_id', 'last_event_id')

      if result == 'success'
        stream = Stream.new(q_id, last, stream_name)
        @streams << stream
      end
    end

    def queue_for_stream(stream_name)
      stream = @streams.detect {|s| s.name == stream_name }

      if stream
        queue = Queue.new
        Thread.new { loop { queue.push(*poll(stream)); sleep 1 } }

        queue
      else
        nil
      end
    end

    def poll(stream) # TODO: make this stream.poll
      uri = URI('https://api.zulip.com/v1/events')
      req = Net::HTTP::Get.new(uri)
      req.basic_auth(@email, @api_key)
      req.set_form_data({queue_id: stream.queue_id, 
                         last_event_id: stream.last_event_id})
      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end
      
      JSON.parse(res.body).fetch('events')
        .map {|m| Message.new(m['content'], m['sender_full_name'], m['id']) }
    end
  end
end
