An attempt at reverse engineering and speeding up the CapMetro app for my use case: view the MetroRapid realtime arrivals *quickly*.

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
- Arrivals for route at stop


GET http://www.capmetro.org/planner/s_nextbus2.asp with querystring

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

```

GET http://www.capmetro.org/planner/s_nextbus2.asp?stopid=5868&output=xml&opt=2


Progress
--

- Set up project, get nearby stops to appear in MapView. ![nearby stops](https://www.dropbox.com/s/h9jicamdr8qotxx/nearbystops.png)
- Add nearby routes view, all from GTFS query ![nearby routes](https://www.dropbox.com/s/7hirgsmnk11dir6/nearby_routes.png)
- Contacted CapMetro regarding realtime data not working anymore.
- CapMetro fixed realtime responses
- There are many good GTFS apps out there, so lets focus on the real problem: finding out when the next 801 bus is coming is too much work with the CapMetro app. Make it easy.
