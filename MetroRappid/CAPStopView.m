//
//  CAPStopView.m
//  MetroRappid
//
//  Created by Luq on 3/7/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPStopView.h"

@implementation CAPStopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)updateFrame
{
    CGRect frame = self.frame;
    frame.size = CGSizeMake(15, 15);
    self.frame = frame;
}

- (void)drawRect:(CGRect)rect
{
    self.layer.backgroundColor = [[UIColor colorWithHue:0.023 saturation:1.000 brightness:0.804 alpha:1] CGColor];
    self.layer.cornerRadius = self.frame.size.width / 2.0f;
    self.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.layer.borderWidth = 3.0f;
}

@end
