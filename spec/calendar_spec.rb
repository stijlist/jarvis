require 'vcr'
require_relative '../spec/vcr_helper.rb'
require_relative '../lib/calendar.rb'

describe Calendar do
    
    it 'lists events' do
      VCR.use_cassette('google-calendar-event-listing') do
        c = Calendar.new
        expect(c.events.count).to be > 1
      end
    end
    
    it 'adds events' do
      VCR.use_cassette('adds-events') do
        c = Calendar.new
        request_sdate = DateTime.new(2014,8,9,10,35).new_offset("-04:00")
        request_edate = DateTime.new(2014,8,9,11,35).new_offset("-04:00")
        room = "Babbage"
        desc = "algebraic data types party!"
        res = c.add(request_sdate, request_edate, room, desc)
        expect(res['status']).to eq('confirmed')
        expect(res['summary']).to eq(desc)
        expect(res['location']).to eq(room)
      end
    end
    
#       event_start ------------------ event_end
#         req_start ------------------ req_end
    it 'indicates not bookable if time/room-combo is booked' do
      VCR.use_cassette('not-bookable-1') do
        c = Calendar.new
        request_sdate = DateTime.new(2014,8,9,10,35).new_offset("-04:00")
        request_edate = DateTime.new(2014,8,9,11,35).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate, request_edate, "Babbage")
        expect(bookable).to eq(false)
      end
    end

#                   event_start ------------------ event_end
#       req_start ------------------ req_end
    it 'indicates not bookable in 1-sided overlapping case' do
      VCR.use_cassette('not-bookable-2') do
        c = Calendar.new
        request_sdate2 = DateTime.new(2014,8,9,10,20).new_offset("-04:00")
        request_edate2 = DateTime.new(2014,8,9,11,00).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate2, request_edate2, "Babbage")
        expect(bookable).to eq(false)
      end
    end

#       event_start ------------------ event_end
#                       req_start ------------------ req_end
    it 'indicates not bookable in 1-sided overlapping case 2' do
      VCR.use_cassette('not-bookable-3') do
        c = Calendar.new
        request_sdate2 = DateTime.new(2014,8,9,10,50).new_offset("-04:00")
        request_edate2 = DateTime.new(2014,8,9,11,50).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate2, request_edate2, "Babbage")
        expect(bookable).to eq(false)
      end
    end

#                   event_start ------------------ event_end
#       req_start ------------------------------------------------------ req_end    
    it 'indicates not bookable in totally overlapping case' do
      VCR.use_cassette('not-bookable-4') do
        c = Calendar.new
        request_sdate2 = DateTime.new(2014,8,9,10,20).new_offset("-04:00")
        request_edate2 = DateTime.new(2014,8,9,11,50).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate2, request_edate2, "Babbage")
        expect(bookable).to eq(false)
      end
    end

#       event_start ------------------------------------------------------ event_end
#                            req_start ------------------ req_end     
    it 'indicates not bookable in totally overlapping case 2' do
      VCR.use_cassette('not-bookable-5') do
        c = Calendar.new
        request_sdate2 = DateTime.new(2014,8,9,10,50).new_offset("-04:00")
        request_edate2 = DateTime.new(2014,8,9,11,00).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate2, request_edate2, "Babbage")
        expect(bookable).to eq(false)
      end
    end
    
    it 'indicates bookable if room is free, even if time is booked' do
      VCR.use_cassette('bookable-1') do
        c = Calendar.new
        request_sdate = DateTime.new(2014,8,9,10,35).new_offset("-04:00")
        request_edate = DateTime.new(2014,8,9,11,35).new_offset("-04:00")
        bookable = c.bookable_for?(request_sdate, request_edate, "Lovelace")
        expect(bookable).to eq(true)
      end
    end
    
    it 'indicates bookable if time/room-combo is free' do
      VCR.use_cassette('bookable-2') do
        c = Calendar.new
        diff_start = DateTime.new(1900,8,9,10,35).new_offset("-04:00")
        diff_end = DateTime.new(1900,8,9,11,35).new_offset("-04:00")

        bookable = c.bookable_for?(diff_start, diff_end, "Lovelace")
        expect(bookable).to eq(true)
      end
    end
end
