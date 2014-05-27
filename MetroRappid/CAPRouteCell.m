//
//  CAPRouteCell.m
//  MetroRappid
//
//  Created by Luq on 5/18/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRouteCell.h"


@implementation CAPRouteCell

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
    self.routeColorView.layer.cornerRadius = 5.0f;
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
