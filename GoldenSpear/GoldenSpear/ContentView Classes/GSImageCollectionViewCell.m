//
//  GSImageCollectionViewCell.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 23/4/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSImageCollectionViewCell.h"

@implementation GSImageCollectionViewCell

- (void)prepareForReuse{
    self.theImage.image = [UIImage imageNamed:@"no-image.png"];
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.theImage = [UIImageView new];
    self.theImage.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.theImage];
    UILongPressGestureRecognizer* longRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self addGestureRecognizer:longRecognizer];
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self.cellDelegate longPressedCell:self];
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.cellDelegate closeQV];
    }
}

- (void)dealloc{
    self.theImage = nil;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.theImage.frame = self.bounds;
}

@end
