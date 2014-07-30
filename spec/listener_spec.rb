require 'rspec'
require_relative '../lib/listener.rb'

describe Listener do
  result = Listener.listen("reserve Hopper Tuesday at 5am")
  it 'understands the reserve command' do
    expect(result[:command]).to eq(:reserve)
  end
  
  it 'parses room names' do
    expect(result[:room]).to eq('Hopper')
  end
  
  it 'parses days' do
    expect(result[:day]).to eq('Tuesday')
  end
end

describe JarvisTime do
  input = "reserve Hopper Tuesday at 5am"
  it 'parses time' do
    expect(JarvisTime.parse(input)).to eq(500)
  end
end
