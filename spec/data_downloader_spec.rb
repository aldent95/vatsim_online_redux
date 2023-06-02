require 'spec_helper.rb'
require 'data_downloader_spec_helper.rb'

describe VatsimTools::DataDownloader do

  target = VatsimTools::DataDownloader
  LOCAL_STATUS = "#{Dir.tmpdir}/vatsim_online/vatsim_status.json"
  LOCAL_DATA = "#{Dir.tmpdir}/vatsim_online/vatsim_data.json"

  before(:each) do
    stub_request(:get, 'https://status.vatsim.net/status.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__),  'support', 'vatsim_status.json')), status: :ok)
    stub_request(:get, 'https://data.vatsim.net:443/v3/vatsim-data.json').
      to_return(body: File.read(File.join(File.dirname(__FILE__), 'support', 'vatsim_data.json')), status: :ok)
  end

  describe "create_status_tempfile" do
    it "should create a file" do
      delete_local_files
      File.exist?(LOCAL_STATUS).should be false
      target.new.create_status_tempfile
      File.exist?(LOCAL_STATUS).should be true
      status = File.open(LOCAL_STATUS)
      status.path.should eq("#{Dir.tmpdir}/vatsim_online/vatsim_status.json")
      status.size.should be > 100
      status.close
    end
  end

  describe "read_status_tempfile" do
    it "should confirm a file exists" do
      target.new.read_status_tempfile
      File.exist?(LOCAL_STATUS).should be true
      status = File.open(LOCAL_STATUS)
      status.size.should be > 100
      status.close
    end
  end

  describe "status_file" do
    it "should return status.txt path" do
      delete_local_files
      File.exist?(LOCAL_STATUS).should be false
      target.new.status_file.class.should eq(String)
      target.new.status_file.should include("vatsim_status.json")
      target.new.status_file.should eq(LOCAL_STATUS)
      target.new.status_file.should eq("#{Dir.tmpdir}/vatsim_online/vatsim_status.json")
      File.exist?(LOCAL_STATUS).should be true
    end
  end

  describe "servers" do
    it "should contain an array of server URLs" do
      File.exist?(LOCAL_STATUS).should be true
      target.new.servers.class.should eq(Array)
      target.new.servers.size.should eq(1)
    end
  end

  describe "create_local_data_file" do
    it "should confirm a file exists" do
      delete_local_files
      File.exist?(LOCAL_DATA).should be false
      target.new.create_local_data_file
      File.exist?(LOCAL_DATA).should be true
      data = File.open(LOCAL_DATA)
      data.path.should eq("#{Dir.tmpdir}/vatsim_online/vatsim_data.json")
      data.size.should be > 100
      data.close
    end
  end

  describe "read_local_datafile" do
    it "should confirm a file exists" do
      target.new.read_local_datafile
      File.exist?(LOCAL_DATA).should be true
      data = File.open(LOCAL_DATA)
      data.size.should be > 100
      data.close
    end
  end

  describe "data_file" do
    it "should contain file path" do
      delete_local_files
      File.exist?(LOCAL_DATA).should be false
      target.new.data_file.class.should eq(String)
      target.new.data_file.should include("vatsim_data.json")
      target.new.data_file.should eq(LOCAL_DATA)
      target.new.data_file.should eq("#{Dir.tmpdir}/vatsim_online/vatsim_data.json")
      File.exist?(LOCAL_DATA).should be true
    end
  end

  describe "new" do
    it "should return" do
      delete_local_files
      File.exist?(LOCAL_DATA).should be false
      File.exist?(LOCAL_STATUS).should be false
      target.new
      File.exist?(LOCAL_DATA).should be true
      File.exist?(LOCAL_STATUS).should be true
      data = File.open(LOCAL_DATA)
      status = File.open(LOCAL_DATA)
      data.size.should be > 100
      status.size.should be > 100
      status.close
      data.close
    end
  end

end
