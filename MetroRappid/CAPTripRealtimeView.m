//
//  CAPTripRealtimeView.m
//  MetroRappid
//
//  Created by Luq on 3/7/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import "CAPTripRealtimeView.h"

@interface CAPTripRealtimeView ()
@property CABasicAnimation *scaleAnimation;
@end


@implementation CAPTripRealtimeView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self) {
        CGRect frame = self.frame;
        frame.size = CGSizeMake(20, 20);
        self.frame = frame;
        self.layer.backgroundColor = [[UIColor colorWithHue:0.023 saturation:1.000 brightness:1.0 alpha:1] CGColor];
        self.layer.cornerRadius = self.frame.size.width / 2.0f;
        self.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.layer.borderWidth = 3.0f;
        self.layer.shadowColor = [[UIColor darkGrayColor] CGColor];
        self.layer.shadowRadius = 3.0f;
        self.layer.shadowOpacity = 0.3f;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        
        self.scaleAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
        self.scaleAnimation.duration = 2.0;
        self.scaleAnimation.fromValue = [NSNumber numberWithFloat:3.0];
        self.scaleAnimation.toValue = [NSNumber numberWithFloat:4.0];
        self.scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        self.scaleAnimation.autoreverses = YES;
        self.scaleAnimation.repeatCount = INFINITY;
        self.scaleAnimation.fillMode = kCAFillModeForwards;
        [self startAnimating];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startAnimating) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    }
    return self;
}
         
- (void)startAnimating
{
    [self.layer addAnimation:self.scaleAnimation forKey:nil];
}

@end
