# vatsim_online

## Changelog

### v. 2.1.1 - 16 Mar 2022

* Fixing a bug with the time diff on the status and data files

### v. 2.1.0 - 20 Apr 2021

* Added the new vatsim_regex_callsign method
* Updated refresh time for data from 3 minutes to 60 seconds

### v. 2.0.1 - 30 Jan 2021

* Updated the code to use the new VATSIM Json data feed

### v. 1.0.1 - 30 Mar 2020

* Small bugfix to the 1.0.0 release

### v. 1.0.0 - 30 Mar 2020

* Updating code to work better with Windows environments

### v. 0.9.1 - 31 Dec 2016

* Maintenance release, updated dependencies

### v. 0.9 - 20 June 2015

* Fixed nil String bug, can select "ALL" (thanks to Pierre Ferran and Florian Rimoli)

### v. 0.8.3 - 10 April 2014

* Fix stale data bug, change data fallback logic

### v. 0.8.2 - 5 October 2013

* Handle undetermined position when drawing gcmap

### v. 0.8.1 - 5 October 2013

* Ignore prefile data

### v. 0.8 - 5 October 2013

* search by callsign implemented

### v. 0.7.4 - 2 August 2013

* fallback scenarios for offline data servers

### v. 0.7.2 - 15 July 2013

* added gemspec license declaration

### v. 0.7.1 - 15 July 2013

* more comprehensive ATC ratings list
* dependencies updated

### v. 0.7.0 - 26 February 2013

* added Ruby 2.0 support

### v. 0.6.2 - 4 January 2013

* updated gem dependencies
* refactored `Station` class for simplicity

### v. 0.6.1 - 08 October 2012

* Fixed pilot station duplication issue when using multiple ICAOs

### v. 0.6.0 - 08 October 2012

* The `vatsim_online` method now also supports a comma-separated list of full or
partial ICAO codes like this: `"LO,LB".vatsim_online`. This allows you to pull the
information for multiple airports or FIRs in a single request
* The comma-seprated list is not sensitive to whitespace, meaning you can use
`"LO,LB".vatsim_online` or `"LO, LB".vatsim_online` or `"LO , LB".vatsim_online` with
the same result

### v. 0.5.3 - 30 September 2012

* fixed bug with exceptions on missing ATC remark

### v. 0.5.2 - 29 September 2012

* fixed permissions bug on UNIX systems

### v. 0.5.1 - 23 September 2012

* bugfixes

### v. 0.5 - 23 September 2012

* New option `:exclude => "ICAO"` allowing further request customization by
excluding a matching subset of ATC stations from the listing. Read the documentation
for detailed explanation and examples
* New customized station attribute: `online_since`. Returns the station login time
parsed as a Ruby Time object in UTC (zulu time). As opposed to the `logon` attribute
which returns an unformatted, unparsed string such as `20120722091954`
* The `rating` station attribute is now humanized not to return just an integer,
but a readable version of the VATSIM rating, i.e. S1, S2, S3, C1, C3, I1, I3, etc...
* Added the possibility of customizing the great circle maps by optionally passing
parameters for width and height: `icao.vatsim_online(:gcmap_width => 400, :gcmap_height => 400)`.
Read the documentation for detailed explanation and examples
* New customized station attribute `atis_message`. It will return a humanized web safe
version of the ATC atis without the voice server info and with lines split with
`<br />` tags. As opposed to the original `atis` attribute, which returns raw atis,
as reported from VATSIM, including voice server as first line

### v. 0.4 - 27 August 2012

* GCMapper integration: this library now plays nicely with [gcmapper](https://rubygems.org/gems/gcmapper).
A new attribute is provided for the pilot stations: `.gcmap` which returns a great
circle map image url, depicting the GC route of the aircraft, its origin and destination,
its current position on the route, together with its current altitude and groundspeed.
Look at the example in the README section above.
* New station attributes: planned_altitude, transponder, heading, qnh_in, qnh_mb,
flight_type, cid, latitude_humanized, longitude_humanized


### v. 0.3 - 22 July 2012

* The hash returned by the `vatsim_online` method now includes 2 new arrays:
`arrivals` and `departures`. These two are returned separately for convenience,
in case you want to loop through them separately. The `pilots` array return is
unchanged and contains all arrivals and departures.
* New station attributes: latitude, longitude
* Improved UTF-8 conversion process

### v. 0.2 - 21 July 2012

* Station attribute `departure` is now renamed to `origin`
* UTF-8 is now enforced for all local caching and file/string manipulations, the
original Vatsim data is re-encoded
* Station ATIS is now cleaned of invalid and obscure characters
* Improved documentation
