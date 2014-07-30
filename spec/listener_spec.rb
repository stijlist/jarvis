require 'rspec'
require_relative '../lib/listener.rb'

describe Listener do
  result = Listener.listen("reserve Hopper Tuesday at 5pm")
  it 'understands the reserve command' do
    expect(result[:command]).to eq(:reserve)
  end
  
  it 'parses room names' do
    expect(result[:room]).to eq('Hopper')
  end
  
  it 'parses days' do
    expect(result[:day]).to eq('Tuesday')
  end
  
  it 'parses time' do
    expect(result[:time]).to eq(1700)
  end
end
