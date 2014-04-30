import sqlite3
import os
import pprint

import arrow
import requests


def stops_for_route(route_id):
    def dict_factory(cursor, row):
        d = {}
        for idx, col in enumerate(cursor.description):
            d[col[0]] = row[idx]
        return d

    conn = sqlite3.connect(
        "MetroRappid/Data/gtfs_austin.db", detect_types=sqlite3.PARSE_COLNAMES)
    cur = conn.cursor()
    cur.row_factory = dict_factory

    query = """
    SELECT unique_stops.route_id,
           unique_stops.trip_id,
           unique_stops.trip_headsign,
           unique_stops.stop_id,
           stop_name,
           stop_desc,
           stop_lat,
           stop_lon,
           unique_stops.stop_sequence,
           unique_stops.direction_id
    FROM   stops,
           (SELECT stop_id,
                   route_id,
                   stop_sequence,
                   unique_trips.trip_id,
                   unique_trips.trip_headsign,
                   unique_trips.direction_id
            FROM   stop_times,
                   (SELECT trip_id,
                           route_id,
                           trip_headsign,
                           direction_id
                    FROM   trips
                    WHERE  route_id IN ( {} )
                    GROUP  BY shape_id) AS unique_trips
            WHERE  stop_times.trip_id = unique_trips.trip_id
            GROUP  BY stop_id) AS unique_stops
    WHERE  stops.stop_id = unique_stops.stop_id
    ORDER  BY unique_stops.stop_sequence;
    """.format(route_id)

    cur.execute(query)

    stops = cur.fetchall()

    return stops


def res_comment(res):
    return '''<!--
        {} {} {}
        {}
-->
    '''.format(res.request.method, res.status_code, res.request.url, pprint.pformat(dict(res.headers)))


def backup_nextbus2(route_id, now):
    stops = stops_for_route(route_id)

    for stop in stops:
        res = requests.get('http://www.capmetro.org/planner/s_nextbus2.asp', params={
            'route': route_id,
            'stopid': stop['stop_id'],
            'opt': 'meow meow meow'
        })

        if not res.ok:
            print 'request failed: {} {}'.format(res.request.url, res.status_code)

        directory = 'MetroRappidTests/Data/s_nextbus2/{}'.format(now.format('YYYY-MM-DD-HH-mm'))
        try:
            os.makedirs(directory)
        except OSError:
            print 'directory already exists'

        fname = '{}/{}-{}-{}.xml'.format(directory, stop['route_id'], stop['stop_id'], res.status_code)
        print 'writing results to {}'.format(fname)

        with open(fname, 'w+') as f:
            f.write(res_comment(res))
            f.write(res.content)


def backup_nextbus(lat, lon, now, route_id=None):
    res = requests.get('http://www.capmetro.org/planner/s_service.asp', params={
        'output': 'xml',
        'opt': 2,
        'tool': 'NB',
        'loc1lat': lat,
        'loc1lng': lon,
        'route': route_id,
    })

    if not res.ok:
        print 'request failed: {} {}'.format(res.request.url, res.status_code)

    directory = 'MetroRappidTests/Data/s_nextbus/{}'.format(arrow.now().format('YYYY-MM-DD-HH-mm'))
    try:
        os.makedirs(directory)
    except OSError:
        pass

    fname = '{}/{}-{}-{}-{}.xml'.format(directory, route_id, lat, lon, res.status_code)
    print 'writing results to {}'.format(fname)

    with open(fname, 'w+') as f:
        f.write(res_comment(res))
        f.write(res.content)


if __name__ == '__main__':
    now = arrow.now()
    backup_nextbus2(801, now)
    backup_nextbus(30.268224, -97.743678, now, route_id=801)
    backup_nextbus(30.268224, -97.743678, now)
