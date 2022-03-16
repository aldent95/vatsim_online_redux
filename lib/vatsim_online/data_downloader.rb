module VatsimTools
require 'tempfile'
require 'time_diff'
require 'tmpdir'
require 'net/http'
require 'fileutils'
  class DataDownloader

    STATUS_URL = "https://status.vatsim.net/status.json"
    TEMP_DIR = "#{Dir.tmpdir}/vatsim_online"
    LOCAL_STATUS = "#{Dir.tmpdir}/vatsim_online/vatsim_status.json"
    LOCAL_STATUS_BAK = "#{Dir.tmpdir}/vatsim_online/vatsim_status_bak.json"
    LOCAL_DATA = "#{Dir.tmpdir}/vatsim_online/vatsim_data.json"
    LOCAL_DATA_BAK = "#{Dir.tmpdir}/vatsim_online/vatsim_data_bak.json"

    def initialize
      FileUtils.mkdir(TEMP_DIR) unless File.exist? TEMP_DIR
      data_file
    end

    def create_status_tempfile
      uri = URI(STATUS_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.path)
      http.use_ssl = (uri.scheme == 'https')
      data = http.request(request).body.gsub("\n", '')
      create_status_backup if File.exists?(LOCAL_STATUS)
      File.write(LOCAL_STATUS, data)
      File.chmod(0777, LOCAL_STATUS)
      dummy_status if data.include? "<html><head>"
    rescue Exception => e
      if e.class == WebMock::NetConnectNotAllowedError
        raise e
      end
      dummy_status
    end

    def create_status_backup
      source = LOCAL_STATUS
      target = LOCAL_STATUS_BAK
      FileUtils.cp_r source, target
      File.chmod(0777, LOCAL_STATUS_BAK)
    end

    def read_status_tempfile
      status = File.open(LOCAL_STATUS)
      difference = Time.diff(status.mtime, Time.now)[:hour]
      if difference > 3
        data = create_status_tempfile
      else
        data = status.read
      end
      status.close
      data
    end

    def status_file
      File.exists?(LOCAL_STATUS) ? read_status_tempfile : create_status_tempfile
      LOCAL_STATUS
    end

    def servers
      raw_data = File.read(status_file)
      data = JSON.parse(raw_data)
      data['data']['v3']
    end

    def create_local_data_file
      uri = URI(servers.sample)
      http = Net::HTTP.new(uri.host, uri.port)
      request = Net::HTTP::Get.new(uri.path)
      http.use_ssl = (uri.scheme == 'https')
      req_data = http.request(request).body
      create_data_backup if File.exists?(LOCAL_DATA)
      File.open(LOCAL_DATA, "w+") {|f| f.write(req_data.force_encoding('UTF-8'))}
      File.chmod(0777, LOCAL_DATA)
      gem_data_file if req_data.include? "<html><head>"
      file = File.open(LOCAL_DATA)
      gem_data_file if file.size == 0
      file.close
    rescue Exception => e
      if e.class == WebMock::NetConnectNotAllowedError
        raise e
      end
      gem_data_file
    end

    def create_data_backup
      source = LOCAL_DATA
      target = LOCAL_DATA_BAK
      FileUtils.cp_r source, target
      File.chmod(0777, LOCAL_DATA_BAK)
    end

    def read_local_datafile
      data = File.open(LOCAL_DATA)
      difference = Time.diff(data.mtime, Time.now)[:second] + (Time.diff(data.mtime, Time.now)[:minute] * 60)
      if difference > 60
        d = create_local_data_file
      else
        d = data.read
      end
      data.close
      d
    end

    def data_file
      File.exists?(LOCAL_DATA) ? read_local_datafile : create_local_data_file
      LOCAL_DATA
    end

    def gem_data_file
      source = LOCAL_DATA_BAK
      target = LOCAL_DATA
      FileUtils.cp_r source, target
      File.chmod(0777, LOCAL_DATA)
    end

    def dummy_status
      source = LOCAL_STATUS_BAK
      target = LOCAL_STATUS
      FileUtils.cp_r source, target
      File.chmod(0777, LOCAL_STATUS)
    end
    def get_data(url)
      uri = URI(url)
      Net::HTTP.get(uri)
    end
  end

end
