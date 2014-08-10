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

  it 'can send messages' do
    c = Zulip::Client.new(jarvis_email, jarvis_key)
    response = c.send_message!('test-bot',
                               'This message is merely a placeholder.',
                               'Testing.')
    expect(response.success?).to be_truthy
    expect(response.id).not_to be_nil
  end

  xit 'can subscribe to messages it is @tagged in' do
    client = Zulip::Client.new(jarvis_email, jarvis_key)
    client.subscribe_to_stream!('test-bots')
    test_message = 'hi, @**jarvis** !'
    Kernel.system('../zulip_test_bot_message_send.sh', test_message)
    expect(client.messages.include?(test_message)).to be_truthy
  end
end
    
# zulip = Zulip::Client.new(key)
# stream = Zulip::Stream.new(options)
# # options: email, key, 
# stream = zulip.stream.new('')
# stream.messages.callback do |message| # will be run every time
#   # run code here
# end
# 
# stream.messages.each do # batch job
# 
# stream.messages.callbacks # returns a list of procs
