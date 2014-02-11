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

GET http://www.capmetro.org/planner/s_nextbus2.asp?stopid=5868&output=xml&opt=2

```
<?xml version="1.0"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" soap:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"><soap:Body><Nextbus2Response xmlns="AT_WEB">
            <Responsecode>0</Responsecode>
            <Version>1.6</Version>
            <Input>
                <Stopid>5868</Stopid>
                <Atisstopid>0</Atisstopid>
                <Landmarkid>0</Landmarkid>
                <Route></Route>
                <Runs>999</Runs>
                <Xmode>BCXTFRSLK123</Xmode>
                <Date>02/09/14</Date>
                <Time>08:48 PM</Time>
            </Input>
            <Stop>
                <Description>REPUBLIC SQUARE STATION (NB)</Description>
                <Area>Austin</Area>
                <Atisstopid>58017</Atisstopid>
                <Stopid>5868</Stopid>
                <Lat>30.266217</Lat>
                <Long>-97.746059</Long>
                <Stopposition>N</Stopposition>
                <Heading>NB</Heading>
                <Side>Near</Side>
                <Stopstatustype>N</Stopstatustype>
            </Stop>
            <Stops>
                <Stop>
                    <Description>REPUBLIC SQUARE STATION (NB)</Description>
                    <Area>Austin</Area>
                    <Atisstopid>58017</Atisstopid>
                    <Stopid>5868</Stopid>
                    <Lat>30.266217</Lat>
                    <Long>-97.746059</Long>
                    <Stopposition>N</Stopposition>
                    <Heading>NB</Heading>
                    <Side>Near</Side>
                    <Stopstatustype>N</Stopstatustype>
                </Stop>
            </Stops>
            <Runs>
                <Run>
                    <Route>801</Route>
                    <Publicroute>801</Publicroute>
                    <Sign>801-N Lamar S Congress-NB</Sign>
                    <Operator>CM</Operator>
                    <Publicoperator>CM</Publicoperator>
                    <Direction>N</Direction>
                    <Status>L</Status>
                    <Servicetype>0</Servicetype>
                    <Routetype>B</Routetype>
                    <Triptime>08:58 PM</Triptime>
                    <Tripid>37154-35</Tripid>
                    <Skedtripid>
                    </Skedtripid>
                    <Adherence>0</Adherence>
                    <Estimatedtime>08:58 PM</Estimatedtime>
                    <Realtime>
                        <Valid>N</Valid>
                        <Adherence>0</Adherence>
                        <Estimatedtime>08:58 PM</Estimatedtime>
                        <Estimatedminutes>
                        </Estimatedminutes>
                        <Polltime></Polltime>
                        <Trend>
                        </Trend>
                        <Speed>0.00</Speed>
                        <Reliable>
                        </Reliable>
                        <Stopped>
                        </Stopped>
                        <Vehicleid></Vehicleid>
                        <Lat>0.000000</Lat>
                        <Long>0.000000</Long>
                    </Realtime>
                    <Block>801-91</Block>
                    <Exception>N</Exception>
                    <Atisstopid>58017</Atisstopid>
                    <Stopid>5868</Stopid>
                </Run>
                <Run>
                    <Route>801</Route>
                    <Publicroute>801</Publicroute>
                    <Sign>801-N Lamar S Congress-NB</Sign>
                    <Operator>CM</Operator>
                    <Publicoperator>CM</Publicoperator>
                    <Direction>N</Direction>
                    <Status>L</Status>
                    <Servicetype>0</Servicetype>
                    <Routetype>B</Routetype>
                    <Triptime>09:28 PM</Triptime>
                    <Tripid>37154-36</Tripid>
                    <Skedtripid>
                    </Skedtripid>
                    <Adherence>0</Adherence>
                    <Estimatedtime>09:28 PM</Estimatedtime>
                    <Realtime>
                        <Valid>N</Valid>
                        <Adherence>0</Adherence>
                        <Estimatedtime>09:28 PM</Estimatedtime>
                        <Estimatedminutes>
                        </Estimatedminutes>
                        <Polltime></Polltime>
                        <Trend>
                        </Trend>
                        <Speed>0.00</Speed>
                        <Reliable>
                        </Reliable>
                        <Stopped>
                        </Stopped>
                        <Vehicleid></Vehicleid>
                        <Lat>0.000000</Lat>
                        <Long>0.000000</Long>
                    </Realtime>
                    <Block>801-50</Block>
                    <Exception>N</Exception>
                    <Atisstopid>58017</Atisstopid>
                    <Stopid>5868</Stopid>
                </Run>
                <Run>
                    <Route>801</Route>
                    <Publicroute>801</Publicroute>
                    <Sign>801-N Lamar S Congress-NB</Sign>
                    <Operator>CM</Operator>
                    <Publicoperator>CM</Publicoperator>
                    <Direction>N</Direction>
                    <Status>L</Status>
                    <Servicetype>0</Servicetype>
                    <Routetype>B</Routetype>
                    <Triptime>09:58 PM</Triptime>
                    <Tripid>37154-37</Tripid>
                    <Skedtripid>
                    </Skedtripid>
                    <Adherence>0</Adherence>
                    <Estimatedtime>09:58 PM</Estimatedtime>
                    <Realtime>
                        <Valid>N</Valid>
                        <Adherence>0</Adherence>
                        <Estimatedtime>09:58 PM</Estimatedtime>
                        <Estimatedminutes>
                        </Estimatedminutes>
                        <Polltime></Polltime>
                        <Trend>
                        </Trend>
                        <Speed>0.00</Speed>
                        <Reliable>
                        </Reliable>
                        <Stopped>
                        </Stopped>
                        <Vehicleid></Vehicleid>
                        <Lat>0.000000</Lat>
                        <Long>0.000000</Long>
                    </Realtime>
                    <Block>801-02</Block>
                    <Exception>N</Exception>
                    <Atisstopid>58017</Atisstopid>
                    <Stopid>5868</Stopid>
                </Run>
            </Runs>
            <Statusinfo>|R,801,N,,</Statusinfo>
            <Requestor>192.168.10.91</Requestor>
            <Host>cmtaatisweb2</Host>
            <Copyright>XML schema Copyright (c) 2003-2013 Trapeze Software ULC, its subsidiaries and affiliates.  All rights reserved.</Copyright>
            <Soapversion>2.6.3 - 09/23/13</Soapversion>
        </Nextbus2Response></soap:Body></soap:Envelope>
```

Progress
--

- Set up project, get nearby stops to appear in MapView. ![nearby stops](https://www.dropbox.com/s/h9jicamdr8qotxx/nearbystops.png)
- Add nearby routes view, all from GTFS query ![nearby routes](https://www.dropbox.com/s/7hirgsmnk11dir6/nearby_routes.png)
- Contacted CapMetro regarding realtime data not working anymore.
