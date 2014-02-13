An attempt at reverse engineering and speeding up the CapMetro app for my use case: view the MetroRapid realtime arrivals *quickly*.

Data
--

- Nearby 801 stops - GTFS
- Next bus - GET http://www.capmetro.org/planner/s_nextbus2.asp?stopid=5619&output=xml&opt=2&min=1&dir=N
- Trip planner - GET http://www.capmetro.org/planner/s_plantrip.asp?loc1lat=30.268224&loc1lng=-97.743678&loc2lat=30.418367&loc2lng=-97.668597

Progress
--

- Set up project, get nearby stops to appear in MapView. ![nearby stops](https://www.dropbox.com/s/h9jicamdr8qotxx/nearbystops.png)
- Add nearby routes view, all from GTFS query ![nearby routes](https://www.dropbox.com/s/7hirgsmnk11dir6/nearby_routes.png)
- Contacted CapMetro regarding realtime data not working anymore.
- CapMetro fixed realtime responses
- There are many good GTFS apps out there, so lets focus on the real problem: finding out when the next 801 bus is coming is too much work with the CapMetro app. Make it easy.
