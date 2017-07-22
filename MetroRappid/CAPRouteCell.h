//
//  CAPRouteCell.h
//  MetroRappid
//
//  Created by Luq on 5/18/14.
//  Copyright (c) 2014 Createch. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CAPRouteCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *routeIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *routeNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *routeColorView;

- (void)setRouteName:(NSString *)text;
- (void)setColor:(UIColor *)color textColor:(UIColor *)textColor;

@end
