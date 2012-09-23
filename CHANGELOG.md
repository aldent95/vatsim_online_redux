# vatsim_online

## Changelog

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