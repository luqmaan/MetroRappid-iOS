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

- (id)initWithStop:(NSString *)stopId
{
    self = [super init];
    if (self) {
        self.trips = [[NSMutableArray alloc] init];
        self.stopId = stopId;
        self.userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    }
    return self;
}

- (void)startUpdates
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer * responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [requestSerializer setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"application/xml" forHTTPHeaderField:@"Content-type"];
    // The next bus API foolishly thinks it is sending HTML back, not XML
    responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/xml", @"text/html", nil];
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    
    NSDictionary *parameters = @{
        // @"routeid": 801,  // optional
        @"stopid": self.stopId,
        @"opt": @"lol_at_ur_bugs__expose_the_real_api",  // number = json, everything else = xml
        @"output": @"xml",  // NOOP, used to work now use bad input to opt to force xml
    };
    
    [manager GET:@"http://www.capmetro.org/planner/s_nextbus2.asp"
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSData *data = (NSData *)responseObject;
             NSString *xml = [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding];
             [self parseXML:xml];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (id)parseXML:(NSString *)xmlString
{
    NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLString:xmlString];
    NSDictionary *data = xmlDict[@"soap:Body"][@"Nextbus2Response"];
    NSArray *runs = data[@"Runs"][@"Run"];
    
    for (NSDictionary *run in runs) {
        [self.trips addObject:[[CAPTrip alloc] initWithNextBusAPI:run]];
    }
    
    return self.trips;
}

@end
