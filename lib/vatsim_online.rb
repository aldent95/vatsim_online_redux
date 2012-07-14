%w{curb csv tempfile tmpdir time_diff vatsim_online/version vatsim_online/station}.each { |lib| require lib }

class String
  def vatsim_online(args={})
    VatsimOnline.vatsim_online(self, args)
  end
end

module VatsimOnline

  def self.vatsim_online(icao, args)
  end


private

  def self.create_status_tempfile
    status = Tempfile.new('vatsim_status')
    status.write(Curl::Easy.perform("http://status.vatsim.net/status.txt").body_str)
    File.rename status.path, "#{Dir.tmpdir}/vatsim_status.txt"
  end

  def self.read_status_tempfile
    status = File.open("#{Dir.tmpdir}/vatsim_status.txt")
    Time.diff(status.ctime, Time.now)[:hour] > 3 ? self.create_status_tempfile : status.read
  end

  def self.status_file
    File.exists?("#{Dir.tmpdir}/vatsim_status.txt") ? self.read_status_tempfile : self.create_status_tempfile
    "#{Dir.tmpdir}/vatsim_status.txt"
  end

  def self.servers
    servers = []
    CSV.foreach(self.status_file, :col_sep =>'=', :row_sep =>:auto) {|row| servers << row[1] if row[0] == "url0"}
    return servers
  end

  def self.data_file
    File.exists?("#{Dir.tmpdir}/vatsim_data.txt") ? self.read_local_datafile : self.create_local_data_file
    "#{Dir.tmpdir}/vatsim_data.txt"
  end

  def self.create_local_data_file
    data = Tempfile.new('vatsim_data', :encoding => 'iso-8859-15')
    data.write(Curl::Easy.perform(self.servers.sample).body_str.gsub(/["]/, '\s').force_encoding('iso-8859-15'))
    File.rename data.path, "#{Dir.tmpdir}/vatsim_data.txt"
  end

  def self.read_local_datafile
    data = File.open("#{Dir.tmpdir}/vatsim_data.txt")
    Time.diff(data.ctime, Time.now)[:minute] > 3 ? self.create_local_data_file : data.read
  end

  def self.stations(icao, role = "all")
    stations = []
    CSV.foreach(self.data_file, :col_sep =>':', :row_sep =>:auto, encoding: "iso-8859-15") do |row|
      callsign = row[0]; origin = row[11]; destination = row[13]; client = row[3]
      stations << row if (callsign.to_s[0..get_query_length(icao)] == icao && client == "ATC") unless role == "pilot"
      stations << row if (origin.to_s[0..get_query_length(icao)] == icao || destination.to_s[0..get_query_length(icao)] == icao) unless role == "atc"
    end
    return stations
  end

  def self.get_query_length(icao)
    icao.length - 1
  end

  def self.station_objects(icao, role = "all")
    station_objects= []
    self.stations(icao, role).each {|station| station_objects << VatsimOnline::Station.new(station) }
    return station_objects
  end

  def self.sort_station_objects(icao, role = "all")
    atc = []; pilots = []
    self.station_objects(icao, role).each {|sobj| sobj.role == "ATC" ? atc << sobj : pilots << sobj}
    return {:atc => atc, :pilots => pilots}
  end

  def self.determine_role(args)
    args[:atc] == false ? role = "pilot" : role = "all"
    args[:pilots] == false ? role = "atc" : role = role
    role = "all" if args[:pilots] == false && args[:atc] == false
    return role
  end

end