require 'spec_helper.rb'
require 'data_downloader_spec_helper'

describe VatsimOnline do

  before(:each) do
    delete_local_files
    stub_request(:get, 'http://status.vatsim.net/status.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__),  'support', 'vatsim_status.json')), status: :ok)
    stub_request(:get, 'http://data.vatsim.net:443/v3/vatsim-data.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__), 'support', 'vatsim_data.json')), status: :ok)
  end

  describe 'vatsim_online' do
    it 'should work :)' do
      'ZGGG'.vatsim_online.class.should eq(Hash)
      'LO'.vatsim_online.class.should eq(Hash)
      'ED'.vatsim_online[:atc].size.should eq(4)
      'EG'.vatsim_online[:pilots].size.should eq(1)
      'EG'.vatsim_online(:pilots => true, :atc => true).class.should eq(Hash)
      'EG'.vatsim_online(:pilots => true, :atc => true)[:atc].size.should eq(1)
      'EG'.vatsim_online(:pilots => true, :atc => true)[:pilots].size.should eq(1)
      'EG'.vatsim_online(:atc => false)[:atc].size.should eq(0)
      'EG'.vatsim_online(:atc => false)[:pilots].size.should eq(1)
      'EG'.vatsim_online(:pilots => false)[:atc].size.should eq(1)
      'EG'.vatsim_online(:pilots => false)[:pilots].size.should eq(0)

      'LO'.vatsim_online[:pilots].first.callsign.should eq('VFE1625')
      'EG'.vatsim_online[:atc].first.callsign.should eq('EGAC_APP')
      'LO'.vatsim_online(:gcmap_width => '400', :gcmap_height => '400')[:pilots].first.gcmap.should eq('http://www.gcmap.com/map?P=LOWS-N50.69043+E5.15406-EGBB%2C+"VFE1625%5Cn35669+ft%5Cn386+kts"%2B%40N50.69043+E5.15406%0d%0a&MS=wls&MR=120&MX=400x400&PM=b:disc7%2b"%25U%25+%28N"')
      'LO'.vatsim_online(:gcmap_width => 400, :gcmap_height => 400)[:pilots].first.gcmap.should eq('http://www.gcmap.com/map?P=LOWS-N50.69043+E5.15406-EGBB%2C+"VFE1625%5Cn35669+ft%5Cn386+kts"%2B%40N50.69043+E5.15406%0d%0a&MS=wls&MR=120&MX=400x400&PM=b:disc7%2b"%25U%25+%28N"')
    end

    it 'should be case insensitive' do
      'eg'.vatsim_online[:atc].size.should eq(1)
      'eg'.vatsim_online[:pilots].size.should eq(1)
      'eg'.vatsim_online(:pilots => true, :atc => true)[:atc].size.should eq(1)
      'eg'.vatsim_online(:pilots => true, :atc => true)[:pilots].size.should eq(1)
    end
  end

  describe 'vatsim_callsign' do
    it 'should work :)' do
      'VFE1625'.vatsim_callsign.class.should eq(Array)
      'VFE1625'.vatsim_callsign.size.should eq(1)
      'VFE1625'.vatsim_callsign.first.callsign.should eq('VFE1625')
      'DAL'.vatsim_callsign.size.should eq(1)
      'DAL'.vatsim_callsign.last.callsign.should eq('DAL2136')
      'DAL, ARG1458'.vatsim_callsign.size.should eq(2)
      'DAL, SX'.vatsim_callsign.size.should eq(2)
      
    end

    it 'should be case insensitive' do
      'vfe1625'.vatsim_callsign.first.callsign.should eq('VFE1625')
    end
  end

end


describe VatsimTools::Station do

  before(:each) do
    delete_local_files
    stub_request(:get, 'http://status.vatsim.net/status.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__),  'support', 'vatsim_status.json')), status: :ok)
    stub_request(:get, 'http://data.vatsim.net:443/v3/vatsim-data.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__), 'support', 'vatsim_data.json')), status: :ok)
  end

  describe 'new object' do
    it 'should return proper attributes' do
      icao = 'EGAC'
      station = VatsimTools::StationParser.new(icao).stations.first
      new_object = VatsimTools::Station.new(station)
      new_object.callsign.should eq('EGAC_APP')
      new_object.name.should eq('Daniel Button')
      new_object.role.should eq('controller')
      new_object.frequency.should eq('130.850')
      new_object.rating.should eq('C1')
      new_object.facility.should eq('5')
      new_object.logon.should eq('2021-01-29T19:11:14.4846565Z')
      new_object.latitude.should eq('')
      new_object.latitude_humanized.should eq(nil)
      new_object.longitude.should eq('')
      new_object.longitude_humanized.should eq(nil)
    end

    it 'should parse Ruby time with online_since attr' do
      icao = 'UMMS'
      station = VatsimTools::StationParser.new(icao).sorted_station_objects[:atc].first
      station.logon.should eq('2021-01-29T19:11:13.0906448Z')
      station.online_since.class.should eq(Time)
      station.online_since.utc?.should eq(true)
      station.online_since.should eq('2021-01-29T19:11:13.0906448Z')
      station.rating.should eq('S2')
    end
  end

  describe 'pilot object' do
    it 'should contain all attributes' do
      icao = 'LSGG'
      station = VatsimTools::StationParser.new(icao).stations.first
      new_object = VatsimTools::Station.new(station)
      new_object.callsign.should eq('AFR352')
      new_object.name.should eq('Michel Matalon LSZH')
      new_object.role.should eq('pilot')
      new_object.latitude.should eq('44.99953')
      new_object.latitude_humanized.should eq('N44.99953')
      new_object.longitude.should eq('9.47403')
      new_object.longitude_humanized.should eq('E9.47403')
      new_object.planned_altitude.should eq('38000')
      new_object.transponder.should eq('4107')
      new_object.heading.should eq('300')
      new_object.qnh_in.should eq('29.64')
      new_object.qnh_mb.should eq('1004')
      new_object.flight_type.should eq('I')
      new_object.cid.should eq('1379490')
    end

    it 'should generate gcmap link' do
      icao = 'LSGG'
      station = VatsimTools::StationParser.new(icao).stations.first
      new_object = VatsimTools::Station.new(station)
      new_object.gcmap.should eq('http://www.gcmap.com/map?P=EDUU-N44.99953+E9.47403-LSGG%2C+"AFR352%5Cn37729+ft%5Cn425+kts"%2B%40N44.99953+E9.47403%0d%0a&MS=wls&MR=120&MX=720x360&PM=b:disc7%2b"%25U%25+%28N"')
    end

    it 'should handle resized gcmap' do
      icao = 'LSGG'
      args = {}
      args[:gcmap_width] = '400'
      args[:gcmap_height] = '400'
      station = VatsimTools::StationParser.new(icao).stations.first
      new_object = VatsimTools::Station.new(station, args)
      new_object.gcmap_width.should eq(400)
      new_object.gcmap_height.should eq(400)
      new_object.gcmap.should eq('http://www.gcmap.com/map?P=EDUU-N44.99953+E9.47403-LSGG%2C+"AFR352%5Cn37729+ft%5Cn425+kts"%2B%40N44.99953+E9.47403%0d%0a&MS=wls&MR=120&MX=400x400&PM=b:disc7%2b"%25U%25+%28N"')

    end

  end

  describe 'atc object' do
    it 'should handle regular and humanized atis' do
      icao = 'EDBB'
      station = VatsimTools::StationParser.new(icao).sorted_station_objects[:atc].first
      station.logon.should eq('2021-01-29T19:11:13.2762054Z')
      station.rating.should eq('C1')
      station.atis.should eq('BERLIN DIRECTOR ON INTIAL CONTACT, STATE YOUR CALLSIGN ONLY')
      station.atis_message.should eq('No published remark')
    end

     it 'should handle no ATC remark' do
      icao = 'EDBB'
      station = VatsimTools::StationParser.new(icao).sorted_station_objects[:atc].first
      station.atis.should eq('BERLIN DIRECTOR ON INTIAL CONTACT, STATE YOUR CALLSIGN ONLY')
      station.atis_message.should eq('No published remark')
    end
  end

end
