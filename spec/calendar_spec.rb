require_relative '../lib/calendar.rb'

describe Calendar do
    c = Calendar.new
    it 'quick adds an event' do
        res = c.quick_add "DID IT WORK???? at 5:25 pm"
        # todo: this test is tightly coupled to the shape of the gcal API! fix if possible
        expect(res['status']).to eq('confirmed')
    end
    
    it 'adds events' do
        sdate = DateTime.new(2014,8,9,10,35).new_offset("-04:00")
        edate = DateTime.new(2014,8,9,11,35).new_offset("-04:00")
        room = "Babbage"
        desc = "algebraic data types party!"
        res = c.add(sdate, edate, room, desc)
        
        expect(res['status']).to eq('confirmed')
        expect(res['summary']).to eq(desc)
        expect(res['location']).to eq(room)
    end
    
    it 'list events' do
        events_list = c.events
        events_list.should have_at_least(1).items
    end
    
    it 'indicates correctly if time slot is booked' do
        pending "completion of this method"
    end
    
    it 'indicates correctly if time slot is free' do
        pending "completion of this method"
    end
end
