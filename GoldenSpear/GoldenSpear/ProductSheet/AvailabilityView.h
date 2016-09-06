//
//  AvailabilityView.h
//  GoldenSpear
//
//  Created by JCB on 8/3/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Product+Manage.h"

@import MapKit;

@protocol Delegate <NSObject>

-(void)onTapSeeMoreAvailability;
-(void)onTapWebSite;
@end

@interface AvailabilityView : UIViewController <MKAnnotation>

@property(nonatomic, retain) id<Delegate> delegate;
@property(nonatomic) BOOL isEnd;
@property(nonatomic) BOOL isFill;
@property(nonatomic) BOOL isShowSeeMore;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic) ProductAvailability *onlineStore;
@property (nonatomic) ProductAvailability *instoreStore;
@property (nonatomic) NSInteger onlinestate;

-(void)initView;
-(void)swipeUp:(NSInteger)height;
-(void)swipeDown;

@end