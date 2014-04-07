//
//  CAPModelUtils.h
//  MetroRappid
//
//  Created by Luq on 4/7/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CAPModelUtils : NSObject

-(NSDate *)dateFromCapMetroTimeString:(NSString *)timeString;
-(NSString *)formattedTimeUntilDate:(NSDate *)date;

@end
