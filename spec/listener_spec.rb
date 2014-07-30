require 'rspec'
require_relative '../lib/listener.rb'

describe Listener do
  result = Listener.listen("reserve Hopper Tuesday at 5pm")
  it 'understands the reserve command' do
    expect(result[:command]).to eq(:reserve)
  end
end
