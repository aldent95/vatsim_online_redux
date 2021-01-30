require 'vatsim_online'
require 'data_downloader_spec_helper'

describe VatsimTools::StationParser do

  target = VatsimTools::StationParser

  before(:each) do
    delete_local_files
    stub_request(:get, 'https://status.vatsim.net/status.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__),  'support', 'vatsim_status.json')), status: :ok)
    stub_request(:get, 'https://data.vatsim.net:443/v3/vatsim-data.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__), 'support', 'vatsim_data.json')), status: :ok)
  end

  describe "determine role" do
    it "should return a role" do
      args = {:pilots => true, :atc => true}
      target.new("loww", args).determine_role(args).should eq("all")
      args = {:pilots => true, :atc => false}
      target.new("loww", args).determine_role(args).should eq("pilot")
      args = {:pilots => false, :atc => true}
      target.new("loww", args).determine_role(args).should eq("atc")
      args = {:pilots => false, :atc => false}
      target.new("loww", args).determine_role(args).should eq("all")
    end

    it "should initialize the instance var" do
      args = {:pilots => true, :atc => true}
      target.new("loww", args).role.should eq("all")
      args = {:pilots => false, :atc => true}
      target.new("loww", args).role.should eq("atc")
    end
  end

  describe "excluded list" do
    it "should not interfere if missing" do
      args = {:exclude => "loww"}
      target.new("loww", args).role.should eq("all")
    end
  end

  describe "stations" do
    args = {:pilots => true, :atc => true}
    it "should return an expected result" do
      icao = "EGAC"
      target.new(icao, args).stations.first['callsign'].should eq("EGAC_APP")
      target.new(icao, args).stations.class.should eq(Array)
    end

    it "should distinguish roles" do
      icao = "EGAC"
      args = {:pilots => false, :atc => true}
      target.new(icao, args).stations.first['callsign'].should eq("EGAC_APP")
      target.new(icao, args).stations.class.should eq(Array)
      args = {:pilots => true, :atc => false}
      target.new(icao, args).stations.length.should be(0)
    end

    it "should combine all stations" do
      icao = "EDU"
      args = {:pilots => true, :atc => true}
      target.new(icao, args).stations.first['callsign'].should eq("AFR352")
      target.new(icao, args).stations.last['callsign'].should eq("EDUU_W_CTR")
      target.new(icao, args).stations.first['flight_plan']['departure'].should eq("EDUU")
      target.new(icao, args).stations.first['flight_plan']['arrival'].should eq("LSGG")
      target.new(icao, args).stations.class.should eq(Array)
      target.new(icao, args).stations.count.should eq(2)
      args = {:pilots => false, :atc => true}
      target.new(icao, args).stations.count.should eq(1)
    end
  end

  describe "station_objects" do
    it "should return an array of Station objects" do
      icao = "LO"
      target.new(icao).station_objects.class.should eq(Array)
      target.new(icao).station_objects.size.should eq(1)
      args = {:pilots => false}
      target.new(icao, args).station_objects.size.should eq(0)
      args = {:atc => false}
      target.new(icao, args).station_objects.size.should eq(1)
      target.new(icao, args).station_objects.first.class.should eq(VatsimTools::Station)
      target.new(icao, args).station_objects.first.callsign.should eq("VFE1625")
    end
  end

  describe "sorted_station_objects" do
    it "should return an hash with arrays of Station objects" do
      icao = "ED"
      target.new(icao).sorted_station_objects.class.should eq(Hash)
      target.new(icao).sorted_station_objects.size.should eq(4)
      target.new(icao).sorted_station_objects[:atc].class.should eq(Array)
      target.new(icao).sorted_station_objects[:pilots].class.should eq(Array)
      target.new(icao).sorted_station_objects[:pilots].size.should eq(1)
      target.new(icao).sorted_station_objects[:atc].size.should eq(4)
      target.new(icao).sorted_station_objects[:atc].first.class.should eq(VatsimTools::Station)
    end

    it "should handle roles" do
      icao = "ED"
      atc = {:pilots => false}
      pilots = {:atc => false}
      target.new(icao, atc).sorted_station_objects.class.should eq(Hash)
      target.new(icao, atc).sorted_station_objects.size.should eq(4)
      target.new(icao, atc).sorted_station_objects[:atc].class.should eq(Array)
      target.new(icao, atc).sorted_station_objects[:pilots].class.should eq(Array)

      target.new(icao, atc).sorted_station_objects[:pilots].size.should eq(0)
      target.new(icao, atc).sorted_station_objects[:atc].size.should eq(4)
      target.new(icao, pilots).sorted_station_objects[:atc].size.should eq(0)
      target.new(icao, pilots).sorted_station_objects[:pilots].size.should eq(1)
      target.new(icao, atc).sorted_station_objects[:atc].first.callsign.should eq("EDUU_W_CTR")
    end

    it "should recognize arrivals and departures" do
      icao = "LO"
      target.new(icao).sorted_station_objects[:pilots].size.should eq(1)
      target.new(icao).sorted_station_objects[:pilots].size.should eq(target.new(icao).sorted_station_objects[:arrivals].size + target.new(icao).sorted_station_objects[:departures].size)
      target.new(icao).sorted_station_objects[:arrivals].size.should eq(0)
      target.new(icao).sorted_station_objects[:departures].size.should eq(1)
    end

    it "should recognize exclusions" do
      icao = "ED"
      target.new(icao).sorted_station_objects[:atc].size.should eq(4)
      args = {:exclude => "EDBB"}
      target.new(icao, args).excluded.should eq("EDBB")
      target.new(icao, args).excluded.length.should eq(4)
      target.new(icao, args).sorted_station_objects[:atc].size.should eq(3)
      args = {:exclude => "EDGG"}
      target.new(icao, args).sorted_station_objects[:atc].size.should eq(2)
      args = {:exclude => "edgg"}
      target.new(icao, args).sorted_station_objects[:atc].size.should eq(2)
    end

    it "should support multiple icaos" do
      icao = "ED"
      target.new(icao).sorted_station_objects[:atc].size.should eq(4)
      target.new(icao).sorted_station_objects[:pilots].size.should eq(1)
      icao = "EG"
      target.new(icao).sorted_station_objects[:pilots].size.should eq(1)
      target.new(icao).sorted_station_objects[:atc].size.should eq(1)
      icao = "ED,EG"
      target.new(icao).sorted_station_objects[:pilots].size.should eq(2)
      target.new(icao).sorted_station_objects[:atc].size.should eq(5)
      icao = "ED, EG"
      target.new(icao).sorted_station_objects[:pilots].size.should eq(2)
      target.new(icao).sorted_station_objects[:atc].size.should eq(5)
      icao = "ED , EG"
      target.new(icao).sorted_station_objects[:pilots].size.should eq(2)
      target.new(icao).sorted_station_objects[:arrivals].size.should eq(1)
      target.new(icao).sorted_station_objects[:departures].size.should eq(1)
      target.new(icao).sorted_station_objects[:atc].size.should eq(5)
    end

  end

end
