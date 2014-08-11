require 'rspec'
require_relative '../lib/listener.rb'

describe Listener do
  result = Listener.listen("reserve Hopper Tuesday at 5am for the ADT party", "@sophia")
  # TODO: 
  xit 'only listens when it is @mentioned'
  xit 'strips @mentions so chronic can parse times properly'

  it 'understands the reserve command' do
    expect(result[:command]).to eq(:reserve)
  end
  
  it 'parses room names' do
    expect(result[:room]).to eq('hopper')
  end

  it 'parses descriptions' do
    expect(result[:description]).to eq('the ADT party')
  end
end
