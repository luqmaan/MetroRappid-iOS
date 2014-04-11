http://metrorappid.com/

[![Build Status](https://travis-ci.org/luqmaan/MetroRappid.svg?branch=dev)](https://travis-ci.org/luqmaan/MetroRappid)

An attempt at reverse engineering and speeding up the CapMetro app for my use case: view the MetroRapid realtime arrivals *quickly*.

If you're interested in working together on this app, please feel free to contact me, fork the repo, open an issue, etc.

![preview](http://metrorappid.com/img/screenshot3-1136.png)

Importing the GTFS data
--

Download the GTFS zip: http://www.capmetro.org/gisdata/google_transit.zip

```
pip install -r requirements.txt
gtfsdb-load --database_url sqlite:///gtfs_austin.db google_transit.zip
```
