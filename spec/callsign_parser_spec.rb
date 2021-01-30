require 'vatsim_online'
require 'data_downloader_spec_helper'

describe VatsimTools::CallsignParser do

  target = VatsimTools::CallsignParser

  before(:each) do
    delete_local_files
    stub_request(:get, 'http://status.vatsim.net/status.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__),  'support', 'vatsim_status.json')), status: :ok)
    stub_request(:get, 'http://data.vatsim.net:443/v3/vatsim-data.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__), 'support', 'vatsim_data.json')), status: :ok)
  end

  describe "stations" do
    it "should return an expected result" do
      callsign = "EGAC"
      target.new(callsign).stations.first['callsign'].should eq("EGAC_APP")
      target.new(callsign).stations.class.should eq(Array)
    end   
  end

  describe "station_objects" do
    it "should return an array of Station objects" do
      callsign = "VFE"
      target.new(callsign).station_objects.class.should eq(Array)
      target.new(callsign).station_objects.size.should eq(2)
      target.new(callsign).station_objects.first.class.should eq(VatsimTools::Station)
      target.new(callsign).station_objects.first.callsign.should eq("VFE1625")
    end
  end

  
end
