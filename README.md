MetroRappid [![Build Status](https://travis-ci.org/luqmaan/MetroRappid.svg?branch=dev)](https://travis-ci.org/luqmaan/MetroRappid)
==

Fast realtime arrival info for Austin's MetroRapid bus. http://metrorappid.com/

An attempt at reverse engineering and speeding up the CapMetro app for my use case: view the MetroRapid realtime arrivals *quickly*.

- [MetroRappid iOS on the the App Store](https://itunes.apple.com/us/app/metrorappid/id827603682?ls=1&mt=8)
- [MetroRappid Android](https://github.com/sethgho/MetroRappidAndroid) (under development)
- [MetroRappid Web](https://github.com/luqmaan/MetroRappidWeb) (under development)

If you're interested in working together on this app, please feel free to contact me, fork the repo, open an issue, etc.


The Data
--

For realtime data, MetroRappid uses CapMetro's hidden and undocumented "API". A [list of endpoints we've found in the API](https://github.com/luqmaan/MetroRappid/wiki/The-CapMetro-API) is available on the wiki. Example responses can be found in [MetroRappidTests/Data](https://github.com/luqmaan/MetroRappid/tree/dev/MetroRappidTests/Data).

For static data, MetroRappid uses the [GTFS files published by CapMetro](http://www.capmetro.org/gisdata/google_transit.zip).

To convert these files into a SQLite file:

```
pip install -r requirements.txt
gtfsdb-load --database_url sqlite:///gtfs_austin.db google_transit.zip
```

