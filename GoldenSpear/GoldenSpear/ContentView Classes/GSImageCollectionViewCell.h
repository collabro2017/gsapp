//
//  GSImageCollectionViewCell.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GSImageCollectionViewCell;

@protocol GSImageCollectionCellDelegate <NSObject>

- (void)longPressedCell:(GSImageCollectionViewCell*)theCell;
- (void)closeQV;

@end

@interface GSImageCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) UIImageView* theImage;
@property (nonatomic, weak) id<GSImageCollectionCellDelegate> cellDelegate;

@end
