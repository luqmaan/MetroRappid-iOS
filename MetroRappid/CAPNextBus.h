//
//  CAPNextBus.h
//  CapMetro
//
//  Created by Luq on 2/13/14.
//  Copyright (c) 2014 Luq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>
#import "CAPStop.h"
#import "CAPTrip.h"

@interface CAPNextBus : NSObject


- (void)updateStop:(CAPStop *)stop
  onProgress:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressCallback
 onCompleted:(void (^)(void))completedCallback
     onError:(void (^)(NSError *))errorCallback;

- (void)updateStop:(CAPStop *)stop
       withXML:(NSString *)xmlString
   onCompleted:(void (^)(void))completedCallback
       onError:(void (^)(NSError *))errorCallback;


@end

