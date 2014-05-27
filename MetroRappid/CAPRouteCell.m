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
    self.routeColorView.backgroundColor = [UIColor clearColor];
    self.routeColorView.layer.borderColor = [color CGColor];
    self.routeColorView.layer.borderWidth = 2.0f;
    self.routeColorView.layer.cornerRadius = 7.0f;
    self.layer.borderColor = [[UIColor colorWithHue:0.500 saturation:0.081 brightness:0.431 alpha:1] CGColor];

    // nope, the colors they use are horrible
    // self.routeIdLabel.textColor = textColor;
}

-(void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.alpha = 0.5f;
    }
    else {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.0f;
        }];
    }
}


@end
