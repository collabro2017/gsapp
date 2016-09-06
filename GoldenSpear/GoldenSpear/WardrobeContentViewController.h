//
//  WardrobeContentViewController.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 04/05/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"

@interface WardrobeContentViewController : BaseViewController

@property GSBaseElement * selectedItem;
@property Wardrobe * shownWardrobe;

// Views to manage moving a item from/to a wardrobe
@property (weak, nonatomic) IBOutlet UIView *moveItemBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *moveItemVCContainerView;
- (void)closeMovingItemHighlightingButton:(UIButton *)button withSuccess:(BOOL) bSuccess;

@property BOOL bEditionMode;

// Search query (if any) that lead the user to this post  (for statistics)
@property SearchQuery * searchQuery;

@end
