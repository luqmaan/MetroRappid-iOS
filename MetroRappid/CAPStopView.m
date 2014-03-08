//
//  CAPStopView.m
//  MetroRappid
//
//  Created by Luq on 3/7/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPStopView.h"

@implementation CAPStopView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(23, 23);
        self.frame = frame;
        self.layer.backgroundColor = [[UIColor colorWithHue:0.023 saturation:1.000 brightness:0.804 alpha:1] CGColor];
        self.layer.cornerRadius = self.frame.size.width / 2.0f;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 3.0f;
        self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOpacity = 0.3f;
        self.layer.shadowOffset = CGSizeMake(0, 0);
    }
    return self;
}

@end
