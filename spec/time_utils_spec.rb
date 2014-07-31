require_relative '../lib/time_utils.rb'
# tests for time utilities
# internal representation of time is military-time integers
describe JarvisTime do
  input = "reserve Hopper Tuesday at 5am"
  it 'parses time' do
    expect(JarvisTime.parse(input)).to eq(500)
  end
end
