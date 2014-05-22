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


@end
