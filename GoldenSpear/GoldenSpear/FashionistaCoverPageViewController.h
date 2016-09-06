//
//  FashionistaCoverPageViewController.h
//  GoldenSpear
//
//  Created by JCB on 9/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "StoryViewController.h"

@class StoryViewController;

@interface FashionistaCoverPageViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property StoryViewController *storyVC;

@end
