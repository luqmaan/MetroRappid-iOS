An attempt at reverse engineering and speeding up the CapMetro app for my use case: view the MetroRapid realtime arrivals *quickly*.

If you're interested in working together on this app, please feel free to contact me, fork the repo, open an issue, etc.

![preview](https://photos-6.dropbox.com/t/0/AACroChi5EbKNBvaTlIuJLw_t8hKNnF9Ub4bDFM0Ku_gjg/12/220760525/png/1024x768/3/1392872400/0/2/iOS%20Simulator%20Screen%20shot%20Feb%2018%2C%202014%2C%2011.40.06%20PM.png/I1HYNeYYAPQIZf_VuQ_wSDXHp1QY0QJME_SlZjqgjyI)

Data
--

- Nearby 801 stops - GTFS
- Next bus - GET http://www.capmetro.org/planner/s_nextbus2.asp?stopid=5619&output=xml&opt=2&min=1&dir=N
- Trip planner - GET http://www.capmetro.org/planner/s_plantrip.asp?loc1lat=30.268224&loc1lng=-97.743678&loc2lat=30.418367&loc2lng=-97.668597

