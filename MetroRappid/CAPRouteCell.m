//
//  CAPRouteCell.m
//  MetroRappid
//
//  Created by Luq on 5/18/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRouteCell.h"


@implementation CAPRouteCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)setRouteName:(NSString *)text
{
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    [paragrahStyle setLineSpacing:0];
    
    NSDictionary *attributes = @{
        NSParagraphStyleAttributeName: paragrahStyle,
    };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];

    self.routeNameLabel.attributedText = attributedString;
}

- (void)setColor:(UIColor *)color textColor:(UIColor *)textColor
{
    self.routeColorView.backgroundColor = color;
    // nope, the colors they use are horrible
    // self.routeIdLabel.textColor = textColor;
}

- (void)appearSelected
{
    self.backgroundColor = [UIColor colorWithHue:0.997 saturation:1.000 brightness:0.773 alpha:1];
    self.routeNameLabel.textColor = [UIColor whiteColor];
    self.routeIdLabel.textColor = [UIColor whiteColor];
}

- (void)appearDeselected
{
    self.backgroundColor = [UIColor clearColor];
    self.routeNameLabel.textColor = [UIColor darkGrayColor];
    self.routeIdLabel.textColor = [UIColor darkGrayColor];
}

@end
