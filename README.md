### :warning: See [metrorappid.com](http://metrorappid.com) :warning:

#### This project is deprecated in favor of [metrorappid.com](http://metrorappid.com) / https://github.com/luqmaan/GhettoRappid. A webapp that works well on the desktop, iOS and Android is much easier to maintain and develop for.



MetroRappid [![Build Status](https://travis-ci.org/luqmaan/MetroRappid-iOS.svg?branch=dev)](https://travis-ci.org/luqmaan/MetroRappid-iOS)
==

Fast realtime arrival info for Austin's MetroRapid bus.

![image](https://user-images.githubusercontent.com/1275831/28501200-8a68aed2-6f9c-11e7-8105-df03d138600d.png) ![image](https://user-images.githubusercontent.com/1275831/28501202-8d3fcd70-6f9c-11e7-8bd9-b95a7dd2d64a.png) ![image](https://user-images.githubusercontent.com/1275831/28501203-8fbcb7d4-6f9c-11e7-8d9f-6fd1483977da.png) <img src="https://user-images.githubusercontent.com/1275831/28501210-c691ee6e-6f9c-11e7-92d4-2958e7e5295b.png" width="300" />



An attempt at reverse engineering and speeding up the CapMetro app for my use case: view the MetroRapid realtime arrivals *quickly*.

- [MetroRappid iOS on the the App Store](https://itunes.apple.com/us/app/metrorappid/id827603682?ls=1&mt=8)
- [MetroRappid Web](https://github.com/luqmaan/GhettoRappid) (under development)
- [MetroRappid Android](https://github.com/sethgho/MetroRappidAndroid) (completed, but we're having some api key issues ;_;)

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

