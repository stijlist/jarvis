require_relative '../lib/time_utils.rb'
# tests for time utilities
# internal representation of time is military-time integers
describe TimeUtils do
  input = "reserve Hopper Tuesday at 5am"
  it 'parses time' do
    expect(TimeUtils.parse(input)).to eq(500)
  end
end
