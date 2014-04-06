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

- (id)init
{
    self = [super init];
    if (self) {
        self.userAgent = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    }
    return self;
}

- (void)updateStop:(CAPStop *)stop
        onProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressCallback
       onCompleted:(void (^)(void))completedCallback
           onError:(void (^)(NSError *))errorCallback
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
    
    NSDictionary *parameters = @{
        @"route": stop.routeId,
        @"stopid": stop.stopId,
        @"opt": @"lol_at_ur_bugs__plz_expose_the_real_api",  // number = json, everything else = xml
        @"output": @"xml",  // NOOP, used to work now use bad input to opt to force xml
    };
    
    NSString *url = @"http://www.capmetro.org/planner/s_nextbus2.asp";
//    url= @"http://localhost:1234/MetroRappidTests/Data/s_nextbus2/801-realtime.xml";
    
    NSLog(@"GET %@ %@", url, parameters);
    operation = [manager GET:url
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSData *data = (NSData *)responseObject;
             NSString *xml = [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding];
             stop.lastUpdated = [NSDate date];
             NSLog(@"About to parse xml");
             [self parseXML:xml forStop:stop onCompleted:completedCallback onError:errorCallback];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             errorCallback(error);
         }];

    [operation setDownloadProgressBlock:progressCallback];
}

- (id)parseXML:(NSString *)xmlString
       forStop:(CAPStop *)stop
   onCompleted:(void (^)(void))completedCallback
       onError:(void (^)(NSError *))errorCallback
{
    [stop.trips removeAllObjects];
    
    @try {
        NSDictionary *xmlDict = [NSDictionary dictionaryWithXMLString:xmlString];
        NSDictionary *data = xmlDict[@"soap:Body"][@"Nextbus2Response"];
        
        if (!data) {
            NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
            errorDetails[NSLocalizedDescriptionKey] = @"Invalid Response";
            NSError *error = [[NSError alloc] initWithDomain:@"soap" code:500 userInfo:errorDetails];
            errorCallback(error);
            return nil;
        }
            
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
        
    }
    @catch (NSException *exception) {
        NSLog(@"Error parsing XML response");
        NSMutableDictionary *errorDetails = [NSMutableDictionary dictionary];
        errorDetails[NSLocalizedDescriptionKey] = @"Invalid Response";
        NSError *error = [[NSError alloc] initWithDomain:@"soap" code:500 userInfo:errorDetails];
        errorCallback(error);
        return nil;
    }
    @finally {
        NSLog(@"Loaded %d trips", (int)stop.trips.count);
        if (completedCallback) completedCallback();
        return stop.trips;
    }
    
}

@end
