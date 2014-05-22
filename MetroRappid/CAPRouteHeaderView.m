//
//  CAPRouteHeaderView.m
//  MetroRappid
//
//  Created by Luq on 5/18/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPRouteHeaderView.h"


@implementation CAPRouteHeaderView

- (void)drawRect:(CGRect)rect
{
    // http://stackoverflow.com/a/22781815/854025
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 0.5f * [[UIScreen mainScreen] scale]);
    CGFloat red, green, blue, alpha;

    // top
    [[UIColor colorWithHue:0.000 saturation:0.000 brightness:0.8 alpha:1] getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(ctx, red, green, blue, alpha);

    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMinY(rect));
    CGContextStrokePath(ctx);

    // bottom border
    [[UIColor colorWithHue:0.000 saturation:0.000 brightness:0.6 alpha:1] getRed:&red green:&green blue:&blue alpha:&alpha];
    CGContextSetRGBStrokeColor(ctx, red, green, blue, alpha);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGContextStrokePath(ctx);
    
//    CALayer *bottomBorder = [CALayer layer];
//    CGRect bottomBorderRect = rect;
//    bottomBorderRect.size.height = 1.0f;
//    bottomBorderRect.origin.y = rect.origin.y + rect.size.height - 1.0f;
//    bottomBorder.frame = bottomBorderRect;
//    bottomBorder.backgroundColor = [[UIColor lightGrayColor] CGColor];
//    [self.layer addSublayer:bottomBorder];
}

@end
