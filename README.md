# Vatsim Online Redux

Original credit for this gem goes to https://github.com/tarakanbg/vatsim_online 

I've updated it to make it work with update to date Ruby and with Windows.
If at any time the original dev comes back, Ill merge this Gem back into theirs.

A Ruby gem for selectively pulling, parsing and displaying Vatsim online
stations data. Essentially it's a "Who's online" library, capable of displaying
online ATC and/or pilots for given airports, areas or globally and to filter by callsign. Stations are
returned as objects, exposing a rich set of attributes. Vatsim data is pulled
on preset intervals and cached locally to avoid flooding the servers.

[![Gem Version](https://badge.fury.io/rb/vatsim_online_redux.png)](http://badge.fury.io/rb/vatsim_online_redux)

## Requirements

[Ruby 2.6.0](http://www.ruby-lang.org/en/downloads/) or higher

## Installation

Add this line to your application's Gemfile:

    gem 'vatsim_online_redux'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install vatsim_online_redux

## Usage

This gem provides two public methods:

* `vatsim_online`, which can be applied to
any string (or variable containing a string) representing a full or partial ICAO
code or a comma-separated list of ICAO codes. The provided ICAO code or fragment
will be used as a search criteria and matched against the current vatsim data.

* `vatsim_callsign`, which can be applied to
any string (or variable containing a string) representing a full or partial pilot or ATC
callsign or a comma-separated list of callsigns. The provided callsign or fragment
will be used as a search criteria and matched against the current vatsim data.

* `vatsim_regex_callsign`, which can be applied to
  any string (or variable containing a string) representing a regular expression or
  a comma-separated list of regular expressions.
  The provided regex will be used as a search criteria and matched against the current vatsim data.

### Filter by ICAO code examples

For example if you want to retrieve all active stations (ATC positions and pilots)
for Vienna airport (ICAO: LOWW), then you can use:

```ruby
# Attaching the method directly to a string:
"LOWW".vatsim_online

# Attaching the method directly to a list of ICAOs:
"LOWW, LOWK".vatsim_online

# Attaching the method to a variable containing a string:
icao = "LOWW"
icao.vatsim_online
```
If you want to retrieve the currently active stations for an entire region
(FIR/ARTCC), then you can use the first 2-3 letters of the region's ICAO name.
For example if you want to pull all the stations active in Austria (ICAO code
for the FIR is LOVV), you can use `"LO"` as your ICAO search string: all Austrian
airports and ATC station callsigns start with `"LO"`:

```ruby
# Attaching the method directly to a string:
"LO".vatsim_online

# Attaching the method to a variable containing a string:
icao = "LO"
icao.vatsim_online

# Attaching the method to a list of ICAOs:
icao = "LO, LB"
icao.vatsim_online
```

When parsing the pilot stations for particular airport or area, the library will
return the pilots that are flying **to or from** the given area or airport,
not the current enroute stations. The discovery algorithm is based on **origin
and destination**.

### Filter by callsign examples

```ruby
# Attaching the method directly to a string:
"BAW".vatsim_callsign # => returns an array of all Speedbird flights as station objects

# Attaching the method to a variable containing a string:
callsign = "BAW"
callsign.vatsim_callsign # => returns an array of all Speedbird flights as station objects

# Attaching the method to a list of callsigns:
callsign = "BAW, RYR"
callsign.vatsim_callsign # => returns an array of all Speedbird and Ryanair flights as station objects
```

### Filter by regex examples

```ruby
# Attaching the method directly to a string:
'BAW\d{3}'.vatsim_regex_callsign # => returns an array of all Speedbird flights with a 3 digit flight number as station objects
```


### Anatomy of method returns

The `vatsim_online` method returns a **hash** of 4 elements: 1) the matching *atc*
stations, 2) all matching *pilots* stations, 3) matching *arrivals*, 4) matching
*departures*. Each of those is an **array**, cosnsisting of
station **objects**. Each of these objects includes a number of **attributes**:

```ruby
icao.vatsim_online # => {:atc => [a1, a2, a3 ...], :pilots => [p1, p2, p3, p4 ...],
                   #    :departures => [p1, p4 ...], :arrivals => [p2, p3...]}

icao.vatsim_online[:atc] #=> [a1, a2, a3 ...]
icao.vatsim_online[:pilots] #=> [p1, p2, p3 ...]
icao.vatsim_online[:departures] #=> [p1, p3 ...]
icao.vatsim_online[:arrivals] #=> [p2, p4 ...]


icao.vatsim_online[:atc].first #=> a1
icao.vatsim_online[:pilots].first #=> p1

a1.callsign #=> "LQSA_TWR"
a1.frequency #=> "118.25"
a1.name #=> "Svilen Vassilev"
a1.rating #=> "S2"
a1.online_since #=> "2012-09-22 10:00:48 UTC"
...

p1.callsign #=> "ACH217S"
p1.departure #=> "LQSA"
p1.destination #=> "LDSP"
p1.remarks #=> "/V/ RMK/CHARTS"
...
```

`Arrivals` and `departures` are returned separately for convenience, in case you
want to loop through them separately. The `pilots` array contains all arrivals
and departures.

The `vatsim_callsign` and `vatsim_regex_callsign` methods return an **array** of all matching stations.

### Station attributes

Here's a complete list of the station object attributes that can be accessed:

* `cid` (VATSIM ID)
* `callsign`
* `name`
* `role`
* `frequency`
* `altitude`
* `planned_altitude` (or FL)
* `heading`
* `groundspeed`
* `transponder`
* `aircraft`
* `origin`
* `destination`
* `route`
* `rating` (returns a humanized version of the VATSIM rating: S1, S2, S3, C1, etc...)
* `facility`
* `remarks`
* `atis` (raw atis, as reported from VATSIM, including voice server as first line)
* `atis_message` (a humanized version of the ATC atis w/o server and with lines split)
* `logon` (login time as unparsed text string: `20120722091954`)
* `online_since` (returns the station login time parsed as a Ruby Time object in UTC)
* `latitude`
* `longitude`
* `latitude_humanized` (e.g. N44.09780)
* `longitude_humanized` (e.g. W58.41483)
* `qnh_in` (indicated QNH in inches Hg)
* `qnh_mb` (indicated QNH in milibars/hectopascals)
* `flight_type` (`I` for IFR, `V` for VFR, etc)
* `gcmap` (returns a great circle map image url)

### Great circle map visualization

The `.gcmap` method, available for all pilot stations, returns a great
circle map image url, depicting the GC route of the aircraft, its origin and destination,
its current position on the route, together with its current altitude and groundspeed.
Example below:

```ruby
icao.vatsim_online[:pilots].first.gcmap #=> image url of the map
```

![GC Map](http://www.gcmap.com/map?P=kdfw-N44.09780+W58.41483-egll,+%22AAL026%5cn37112+ft%5cn516+kts%22%2b%40N44.09780+W58.41483&MS=wls&MR=540&MX=720x360&PM=*)

The map size (width and height) and scale **can be customized** by passing an
optional hash of arguments to the `vatsim_online` method like this:

```ruby
icao.vatsim_online(:gcmap_width => "400", :gcmap_height => "400")[:pilots].first.gcmap #=> image url of the map

# The quotes are optional, so the statement can also be written like this:
icao.vatsim_online(:gcmap_width => 400, :gcmap_height => 400)[:pilots].first.gcmap
```
![GC Map](http://www.gcmap.com/map?P=kdfw-N44.09780+W58.41483-egll,+%22AAL026%5cn37112+ft%5cn516+kts%22%2b%40N44.09780+W58.41483&MS=wls&MR=540&MX=400x400&PM=*)

### Customizing the request

The `vatsim online` method can be customized by passing in a hash-style collection
of arguments. The currently supported arguments and their defaults are:

```ruby
:atc => true     # Possible values: true, false. Default: true
:pilots => true  # Possible values: true, false. Default: true
:exclude => "ICAO" # Accepts any full or partial ICAO code to be excluded from the ATC stations
:gcmap_width => integer # Optional parameter customizing the width of the station's `.gcmap`
:gcmap_height => integer # Optional parameter customizing the height of the station's `.gcmap`
```
#### ATC exclusions

The `:exclude => "ICAO"` option can be used to exclude matching stations from the
ATC listing. It accepts full or partial ICAO codes or callsigns.

For example you might want to display all Austrian ATC stations by calling
`"LO".vatsim_online`. Seems logical since all Austrian stations callsigns begin
with the `LO` prefix. However a few UK stations (London Control for example) also
have callsigns beginning with `LO` (*LON_CTR*). To avoid including them, you can
use the `:exclude` option on your request like this:

```ruby
# Lets exclude all ATC station names beginning with LON from our request
"LO".vatsim_online(:exclude => "LON")[:atc] #=> [atc1, atc2, atc3...]

# This option is not case sensitive so we can use "lon" as well:
"LO".vatsim_online(:exclude => "lon")[:atc] #=> [atc1, atc2, atc3...]
```

#### ATC and PILOTS options

Both options can be used to exclude **all** ATC or pilots stations respectively from
the request, in order to speed it up and avoid processing useless data.

**Examples:**

```ruby
# Lets exclude all ATC from our request and get the pilots only
"LO".vatsim_online(:atc => false)[:pilots] #=> [p1, p2, p3...]

# Lets exclude all pilots from our request and get the ATC only
"LO".vatsim_online(:pilots => false)[:atc] #=> [a1, a2, a3...]

"LO".vatsim_online(:atc => false)[:pilots].first.callsign #=> "ACH0838"
"LO".vatsim_online(:pilots => false)[:atc].first.callsign #=> "LOVV_CTR"

```

### Example of Ruby on Rails implementation

Here's a possible scenario of using this gem in a Ruby on Rails application.
Verbosity is kept on purpose for clarity.

**In your controller:**
```ruby
def index
  # We want to retrieve all Austrian online stations (ATC and pilots)
  icao = "LO"
  stations = icao.vatsim_online

  # Now we will assign the ATCs and the pilots to separate instance variables,
  # to be able to loop through them separately in the view
  @atc = stations[:atc]
  @pilots = stations[:pilots]

  # We can also isolate the departures and/or arrivals for conveneinence if we
  # want to loop through them separately
  @departures = stations[:departures]
  @arrivals = stations[:arrivals]
end
```

**In your view (HAML is used for clarity):**

```haml
- for atc in @atc
  %li
    = atc.callsign
    = atc.frequency
    = atc.rating
    = atc.name
    = atc.online_since
    = atc.atis_message

- for pilot in @pilots
  %li
    = pilot.callsign
    = pilot.name
    = pilot.origin
    = pilot.destination
    = pilot.route
    = pilot.flight_type
    = pilot.altitude
    = pilot.groundspeed
    = pilot.heading
    = pilot.remarks
    = pilot.online_since
    = image_tag pilot.gcmap

- for arrival in @arrivals
  %li
    = arrival.callsign
    = arrival.name
    = image_tag arrival.gcmap

- for departure in @departures
  %li
    = departure.callsign
    = departure.name
    = image_tag departure.gcmap
```

### Notes

* Vatsim status and data files are cached locally to reduce the load on vatsim
servers. Random server is chosen to retrieve the data each time. By default the
status file is updated once every 4 hours and the data file once every minute
regardless of the number of incoming requests.
* The data is cached in your default TEMP directory (OS specific)
* All the data retrieval and caching logic is encapsulated in a separate class
`VatsimTools::DataDownloader` which can be mixed in other applications and
libraries too.
* The ICAO string used as a search criteria **is not** case sensitive
* Pilot stations returned are based on origin and destination airports, the
current algorithm does not evaluate enroute flights.
* When attaching the `vatsim_online` method to a comma-separated list of full or
partial ICAO identifiers it does not matter whether there will be any spaces in
front or after the identifiers or the commas, i.e. you can use
`"LO,LB".vatsim_online` or `"LO, LB".vatsim_online` or `"LO , LB".vatsim_online` with
the same result.

## Credits

Copyright © 2016 [Svilen Vassilev](http://svilen.rubystudio.net)
Copyright © 2020 [Alex Dent](https://github.com/aldent95)

### Contributors

* [Florian Rimoli](https://github.com/Flox06)
* [Pierre Ferran](https://github.com/pierr3)

Released under the [MIT LICENSE](https://github.com/tarakanbg/vatsim_online_redux/blob/master/LICENSE)

Maps generated by the [Great Circle Mapper](http://www.gcmap.com/), copyright Karl L. Swartz
