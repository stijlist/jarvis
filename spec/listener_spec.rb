require 'rspec'
require_relative '../lib/listener.rb'

describe Listener do
  result = Listener.listen("reserve Hopper Tuesday at 5am for the ADT party", "@sophia")

  it 'understands the reserve command' do
    expect(result[:command]).to eq(:reserve)
  end
  
  it 'parses room names' do
    expect(result[:room]).to eq('hopper')
  end

  it 'parses descriptions' do
    expect(result[:description]).to eq('the ADT party')
  end

  it 'doesn\'t choke on @-@mentions' do
    expect {
      Listener.listen("@jarvis reserve Hopper Tuesday at 5am for the ADT party", "@sophia")
    }.not_to raise_error
  end
end
