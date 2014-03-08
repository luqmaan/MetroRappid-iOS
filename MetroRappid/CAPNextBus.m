//
//  CAPNextBus.m
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import "CAPNextBus.h"
#import <XMLDictionary/XMLDictionary.h>

@interface CAPNextBus()

@property NSString *userAgent;

@end

@implementation CAPNextBus

- (id)initWithLocation:(CAPLocation *)location andRoute:(NSString *)routeId
{
    self = [super init];
    if (self) {
        self.location = location;
        self.activeStopIndex = 0;
        self.userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
        self.routeId = routeId;
    }
    return self;
}

- (NSString *)description
{
    CAPStop *activeStop = self.location.stops[self.activeStopIndex];
    return [NSString stringWithFormat:@"<CAPNextBus: location = %@; activeStopIndex = %d; activeStop = %@;>", self.location, self.activeStopIndex, activeStop];
}

- (void)activateNextStop
{
    if (self.activeStopIndex + 1 < self.location.stops.count) self.activeStopIndex += 1;
    else self.activeStopIndex = 0;
    NSLog(@"New activeStopIndex %d / %d", self.activeStopIndex, (int)self.location.stops.count - 1);
}

- (void)startUpdates
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    AFHTTPRequestOperation *operation;
    
    [requestSerializer setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Content-type"];
    // The next bus API foolishly thinks it is sending HTML back, not XML
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", @"application/xml", @"text/html", nil];
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    
    CAPStop *activeStop = self.location.stops[self.activeStopIndex];
    NSDictionary *parameters = @{
        @"route": self.routeId,
        @"stopid": activeStop.stopId,
        @"opt": @"lol_at_ur_bugs__plz_expose_the_real_api",  // number = json, everything else = xml
        @"output": @"xml",  // NOOP, used to work now use bad input to opt to force xml
    };
    
    NSString *url = @"http://www.capmetro.org/planner/s_nextbus2.asp";
//    url= @"http://localhost:1234/MetroRappidTests/Data/s_nextbus2/801-realtime.xml";
//    url= @"http://localhost:1234/MetroRappidTests/Data/s_nextbus2/801-realtime-no-realtime-arrivals.xml";
//    url= @"http://localhost:1234/MetroRappidTests/Data/s_nextbus2/801-realtime-one-realtime-arrival.xml";
    
    NSLog(@"GET %@ %@", url, parameters);
    operation = [manager GET:url
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSData *data = (NSData *)responseObject;
             NSString *xml = [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding];
             activeStop.lastUpdated = [NSDate date];
             NSLog(@"About to parse xml");
             [self parseXML:xml forStop:activeStop];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             self.errorCallback(error);
         }];
    [operation setDownloadProgressBlock:self.progressCallback];
}

- (id)parseXML:(NSString *)xmlString forStop:(CAPStop *)stop
{
    // pass stop because activeStop may change before parseXML is called
    NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLString:xmlString];
    NSDictionary *data = xmlDict[@"soap:Body"][@"Nextbus2Response"];

    [stop.trips removeAllObjects];
    NSLog(@"Stop.trips has %d objects", (int)stop.trips.count);

    if ([data[@"Runs"][@"Run"] isKindOfClass:[NSArray class]]) {
        NSArray *runs = data[@"Runs"][@"Run"];
        for (NSDictionary *run in runs) {
            CAPTrip *trip = [[CAPTrip alloc] init];
            [trip updateWithNextBusAPI:run];
            [stop.trips addObject:trip];
        }
    }
    else if ([data[@"Runs"][@"Run"] isKindOfClass:[NSDictionary class]]) {
        NSDictionary *run = data[@"Runs"][@"Run"];
        CAPTrip *trip = [[CAPTrip alloc] init];
        [trip updateWithNextBusAPI:run];
        [stop.trips addObject:trip];
    }
    
    NSLog(@"Loaded %d trips", (int)stop.trips.count);

    if (self.completedCallback) self.completedCallback();
    
    return stop.trips;
}

@end
