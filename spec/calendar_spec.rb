require_relative '../lib/calendar.rb'

describe Calendar do
    c = Calendar.new
    
    it 'list events' do
        events_list = c.events
        events_list.should have_at_least(1).items
    end
    
    it 'quick adds an event' do
        res = c.quick_add "DID IT WORK???? at 5:25 pm"
        # todo: this test is tightly coupled to the shape of the gcal API! fix if possible
        expect(res['status']).to eq('confirmed')
    end
    
    request_sdate = DateTime.new(2014,8,9,10,35).new_offset("-04:00")
    request_edate = DateTime.new(2014,8,9,11,35).new_offset("-04:00")
    room = "Babbage"
    desc = "algebraic data types party!"
    res = c.add(request_sdate, request_edate, room, desc)
    
    it 'adds events' do
        expect(res['status']).to eq('confirmed')
        expect(res['summary']).to eq(desc)
        expect(res['location']).to eq(room)
    end
    
#       event_start ------------------ event_end
#         req_start ------------------ req_end
    it 'indicates not bookable if time/room-combo is booked' do
        bookable = c.bookable_for?(request_sdate, request_edate, "Babbage")
        expect(bookable).to eq(false)
    end

#                   event_start ------------------ event_end
#       req_start ------------------ req_end
    it 'indicates not bookable in 1-sided overlapping case' do
        request_sdate2 = DateTime.new(2014,8,9,10,20).new_offset("-04:00")
        request_edate2 = DateTime.new(2014,8,9,11,00).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate2, request_edate2, "Babbage")
        expect(bookable).to eq(false)
    end

#       event_start ------------------ event_end
#                       req_start ------------------ req_end
    it 'indicates not bookable in 1-sided overlapping case 2' do
        request_sdate2 = DateTime.new(2014,8,9,10,50).new_offset("-04:00")
        request_edate2 = DateTime.new(2014,8,9,11,50).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate2, request_edate2, "Babbage")
        expect(bookable).to eq(false)
    end

#                   event_start ------------------ event_end
#       req_start ------------------------------------------------------ req_end    
    it 'indicates not bookable in totally overlapping case' do
        request_sdate2 = DateTime.new(2014,8,9,10,20).new_offset("-04:00")
        request_edate2 = DateTime.new(2014,8,9,11,50).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate2, request_edate2, "Babbage")
        expect(bookable).to eq(false)
    end

#       event_start ------------------------------------------------------ event_end
#                            req_start ------------------ req_end     
    it 'indicates not bookable in totally overlapping case 2' do
        request_sdate2 = DateTime.new(2014,8,9,10,50).new_offset("-04:00")
        request_edate2 = DateTime.new(2014,8,9,11,00).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate2, request_edate2, "Babbage")
        expect(bookable).to eq(false)
    end
    
    it 'indicates bookable if room is free, even if time is booked' do
        bookable = c.bookable_for?(request_sdate, request_edate, "Lovelace")
        expect(bookable).to eq(true)
    end
    
    it 'indicates bookable if time/room-combo is free' do
        diff_start = DateTime.new(1900,8,9,10,35).new_offset("-04:00")
        diff_end = DateTime.new(1900,8,9,11,35).new_offset("-04:00")

        bookable = c.bookable_for?(diff_start, diff_end, "Lovelace")
        expect(bookable).to eq(true)
    end
end
