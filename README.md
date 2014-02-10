An attempt at reverse engineering and speeding up the CapMetro app for my use case.

Notes
--

- Planner http://www.capmetro.org/planner/
- Arrivals http://www.capmetro.org/info/
- GTFS http://www.gtfs-data-exchange.com/agency/capital-metro/
- GTFS to SQLite https://code.google.com/p/googletransitdatafeed/wiki/TransitFeed

Data
--

- Stops for location - Use GTFS data
- Routes for stop - Use GTFS data

Arrivals for route at stop - POST http://www.capmetro.org/planner/s_nextbus2.asp with querystring

Querystring params:

```
    stopid:5868
    route:801
    dir:N
    output:json
    opt:2
    min:1
```
Response:

```
{
    "status": "OK",
    "routeDesc": "801-N Lamar S Congress-NB",
    "stopDesc": "REPUBLIC SQUARE STATION (NB)",
    "list": [{
        "sched": "02:08 PM",
        "est": "02:08 PM",
        "estMin": 4,
        "real": false,
        "vId": ""
    }, {
        "sched": "02:28 PM",
        "est": "02:28 PM",
        "estMin": 24,
        "real": false,
        "vId": ""
    }, {
        "sched": "02:48 PM",
        "est": "02:48 PM",
        "estMin": 44,
        "real": false,
        "vId": ""
    }]
}
```
