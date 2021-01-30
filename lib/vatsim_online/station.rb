# encoding: utf-8
module VatsimTools
  class Station
    require "gcmapper"

    attributes = %w{callsign name role frequency altitude groundspeed aircraft
      origin destination rating facility remarks route atis logon latitude longitude
      planned_altitude transponder heading qnh_in qnh_mb flight_type cid gcmap
      latitude_humanized longitude_humanized online_since gcmap_width gcmap_height
      atis_message}
    attributes.each {|attribute| attr_accessor attribute.to_sym }

    def initialize(station, args = nil)

      @callsign = station['callsign']
      @cid = station['cid'].to_s
      @name = station['name']
      @role = station['role']
      @frequency = station['frequency']
      @latitude = station['latitude'].to_s
      @longitude = station['longitude'].to_s
      @altitude = station['altitude']
      @groundspeed = station['groundspeed']
      @aircraft = station['flight_plan']['aircraft'] rescue ''
      @origin = station['flight_plan']['departure'] rescue ''
      @planned_altitude = station['flight_plan']['altitude'] rescue ''
      @destination = station['flight_plan']['arrival'] rescue ''
      @transponder = station['transponder']
      @facility = station['facility'].to_s
      @flight_type = station['flight_plan']['flight_rules'] rescue ''
      @remarks = station['flight_plan']['remarks'] rescue ''
      @route  = station['flight_plan']['route'] rescue ''
      @logon = station['logon_time']
      @heading = station['heading'].to_s
      @qnh_in = station['qnh_i_hg'].to_s
      @qnh_mb = station['qnh_mb'].to_s

      @atis = atis_cleaner(station['text_atis']) if station['text_atis']
      @rating = humanized_rating(station['rating'].to_s)
      @latitude_humanized = latitude_parser(station['latitude'])
      @longitude_humanized = longitude_parser(station['longitude'])
      @online_since = utc_logon_time if @logon
      @gcmap_width = args[:gcmap_width].to_i if args && args[:gcmap_width]
      @gcmap_height = args[:gcmap_height].to_i if args && args[:gcmap_height]
      @gcmap = gcmap_generator
      @atis_message = construct_atis_message(station['text_atis']) if station['text_atis']
    end

  private

    def gcmap_generator
      return "No map for ATC stations" if @role != "pilot"
      construct_gcmap_url.gcmap(:width => @gcmap_width, :height => @gcmap_height)
    end

    def construct_gcmap_url
      if @origin && @latitude_humanized && @longitude_humanized && @destination
        route = @origin.to_s + "-" + @latitude_humanized.to_s + "+" + @longitude_humanized.to_s + "-" + @destination.to_s
        route += "%2C+\"" + @callsign.to_s + "%5Cn" + @altitude.to_s + "+ft%5Cn" + @groundspeed.to_s + "+kts"
        route += "\"%2B%40" + @latitude_humanized.to_s + "+" + @longitude_humanized.to_s
      else
        route = "Position undetermined"
      end
      route
    end

    def latitude_parser(lat_s)
      return nil if lat_s == nil
      lat = lat_s.to_f
      lat > 0 ? hemisphere = "N" : hemisphere = "S"
      hemisphere + lat.abs.to_s
    end

    def longitude_parser(lon_s)
      return nil if lon_s == nil
      lon = lon_s.to_f
      lon > 0 ? hemisphere = "E" : hemisphere = "W"
      hemisphere + lon.abs.to_s
    end

    def atis_cleaner(raw_atis)
      raw_atis.join(' ').gsub(/[\^]/, '. ')
    end

    def utc_logon_time
      Time.parse(@logon)
    end

    def humanized_rating(rating_number)
      case rating_number
        when "0" then "Suspended"
        when "1" then "OBS"
        when "2" then "S1"
        when "3" then "S2"
        when "4" then "S3"
        when "5" then "C1"
        when "7" then "C3"
        when "8" then "INS"
        when "10" then "INS+"
        when "11" then "Supervisor"
        when "12" then "Administrator"
        else
          "UNK"
      end
    end

    def construct_atis_message(raw_atis)
      message = raw_atis.join(' ').gsub(/[\^]/, '<br />')
      message.index('>') ? message = message[message.index('>')+1...message.length] : message = "No published remark"
    end

  end
end
