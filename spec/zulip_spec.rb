require_relative '../lib/zulip.rb'

describe Zulip do
  jarvis_key = ENV['JARVIS_API_KEY']
  jarvis_email = ENV['JARVIS_EMAIL_ADDRESS']

  # NOTE: this is probably a bad practice, as my unit tests
  # are likely the wrong place to be concerned with devops/config 
  it 'is accessing the correct api keys from the environment' do
    expect(jarvis_key).not_to be_nil
    expect(jarvis_email).not_to be_nil
  end

  it 'is initialized with an api key' do
    Zulip::Client.new(jarvis_email, jarvis_key)
  end

  xit 'can send messages' do
    c = Zulip::Client.new(jarvis_email, jarvis_key)
    response = c.send_message!('test-bot',
                               'This message is merely a placeholder.',
                               'Testing.')
    expect(response.success?).to be_truthy
    expect(response.id).not_to be_nil
  end

  it 'can register for stream updates' do
    c = Zulip::Client.new(jarvis_email, jarvis_key)
    c.register_for_stream('test-bot')
    expect(c.streams).not_to be_empty
  end

  it 'can poll zulip for updates to a stream' do
    c = Zulip::Client.new(jarvis_email, jarvis_key)
    c.register_for_stream('test-bot')
    c.poll(c.streams.first)
  end

  it 'can return a queue for a stream' do
    c = Zulip::Client.new(jarvis_email, jarvis_key)
    q = c.queue_for_stream('test-bot')
  end

  xit 'can retrieve new messages from a queue' do
    client = Zulip::Client.new(jarvis_email, jarvis_key)
    client.register_for_stream('test-bot')
    require 'pry'
    binding.pry
    q = client.queue_for_stream('test-bot')
    msg = q.pop
    expect(msg.content).not_to be_nil
    expect(msg.id).not_to be_nil
    expect(msg.user).not_to be_nil
  end
end
