An attempt at reverse engineering and speeding up the CapMetro app for my use case: view the MetroRapid realtime arrivals *quickly*.

If you're interested in working together on this app, please feel free to contact me, fork the repo, open an issue, etc.

![feb 17 2014](https://photos-2.dropbox.com/t/0/AAB4sWs80h6P7ni-Gfv_kb4fDnnmnWucZoy5PowWgGl32Q/12/220760525/png/1024x768/3/1392706800/0/2/iOS%20Simulator%20Screen%20shot%20Feb%2017%2C%202014%2C%2011.27.26%20PM.png/TeE95CF-kuuXMfA4Jk2Im1svr6Sl3GEEQcAaxKZwRyk)

Data
--

- Nearby 801 stops - GTFS
- Next bus - GET http://www.capmetro.org/planner/s_nextbus2.asp?stopid=5619&output=xml&opt=2&min=1&dir=N
- Trip planner - GET http://www.capmetro.org/planner/s_plantrip.asp?loc1lat=30.268224&loc1lng=-97.743678&loc2lat=30.418367&loc2lng=-97.668597

