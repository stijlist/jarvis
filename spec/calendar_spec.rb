require_relative '../lib/calendar.rb'

describe Calendar do
    it 'works' do
        c = Calendar.new
        c.events
        res = c.quick_add "DID IT WORK???? at 5:25 pm"
        # todo: this test is tightly coupled to the shape of the gcal API! fix if possible
        expect(res['status']).to eq('confirmed')
    end
end
