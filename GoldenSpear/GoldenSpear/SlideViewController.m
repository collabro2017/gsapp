//
//  SlideViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/3/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "SlideViewController.h"

@interface SlideViewController()

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *slideView;
@property (weak, nonatomic) IBOutlet UIView *fullCaptionView;
@property (weak, nonatomic) IBOutlet UILabel *aheadLabel;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aheadLabelHeightConstraint;

@end

@implementation SlideViewController {
    NSMutableArray *imageViews;
    NSString *aheadStr;
    NSInteger currentIndex;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    aheadStr = @"Full Speed Ahead \"I'm just more intense than you assume. I'm very competitive.\" says Hadid, putting this Emilio Pucci jumpsuit ($2,850: select Emilio Pucci boutiques), with its long sleeves and graphic color blocking, through its paces. DKNY V-neck dress, $698:select DKNY stores. Stella McCartney earing.";
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    
    imageViews = [[NSMutableArray alloc] init];
    NSArray *imgs = [[NSArray alloc] initWithObjects:@"art3.png", @"art4.png", @"art5.png", @"art6.png", @"art7.png", @"art8.png", @"art9.png", nil];
    
    for (int i = 0; i < [imgs count]; i ++) {
        NSString *str = (NSString*)[imgs objectAtIndex:i];
        if (str != nil) {
            UIImageView *view = [[UIImageView alloc] init];
            view.image = [UIImage imageNamed:str];
            view.frame = CGRectMake(0, 0, self.slideView.frame.size.width, self.slideView.frame.size.height);
            view.contentMode = UIViewContentModeScaleAspectFit;
            
            [imageViews addObject:view];
        }
    }
    
    UIImageView *firstView = (UIImageView*)[imageViews objectAtIndex:0];
    [self.slideView addSubview:firstView];
    
    NSMutableAttributedString *aheadAttr = [[NSMutableAttributedString alloc] initWithString:aheadStr];
    
    NSRange headRange = [aheadStr rangeOfString:@"Full Speed Ahead"];
    
    [aheadAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:18] range:headRange];

    _aheadLabel.attributedText = aheadAttr;
    
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width, FLT_MAX);
    
    CGSize aheadLabelExpectedSize = [aheadStr sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] constrainedToSize:maximumLabelSize lineBreakMode:_aheadLabel.lineBreakMode];
    
    _aheadLabelHeightConstraint.constant = aheadLabelExpectedSize.height;
    
    UISwipeGestureRecognizer *rightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGesture:)];
    rightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.slideView addGestureRecognizer:rightGesture];
    
    UISwipeGestureRecognizer *leftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(onSwipeGesture:)];
    leftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    
    [self.slideView addGestureRecognizer:leftGesture];
    
    currentIndex = 0;
    
    _fullCaptionView.clipsToBounds = YES;
    _fullCaptionView.layer.cornerRadius = 10;
    
    CGRect frame = _fullCaptionView.frame;
    frame.origin.x = 20;
    _fullCaptionView.frame = frame;
    
    if (_isHideFullCaption) {
        _fullCaptionView.hidden = YES;
    }
    else {
        _fullCaptionView.hidden = NO;
    }
}

- (IBAction)hideFullCaptionView:(id)sender {
    CGRect frame = _fullCaptionView.frame;
    frame.origin.x = self.view.frame.size.width;
    
    [UIView animateWithDuration:0.6
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         _fullCaptionView.frame = frame;
                     }
                     completion:^(BOOL finished){
                     }];
    _isHideFullCaption = YES;
}
- (IBAction)onTapClose:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onSwipeGesture:(UISwipeGestureRecognizer*)sender {
    if (sender.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@" *** Swipe Left ***");
        if (currentIndex < [imageViews count] - 1) {
            [self slideImageView:currentIndex + 1 isLeft:YES];
        }
        else if (currentIndex == [imageViews count] - 1) {
            [self slideImageView:0 isLeft:YES];
        }
    }
    if (sender.direction == UISwipeGestureRecognizerDirectionRight)
    {
        NSLog(@" *** Swipe Right *** ");
        if (currentIndex > 0) {
            [self slideImageView:currentIndex - 1 isLeft:NO];
        }
        else if (currentIndex == 0) {
            NSInteger index = [imageViews count] - 1;
            [self slideImageView:index isLeft:NO];
        }
    }
}

-(void)slideImageView:(NSInteger)index isLeft:(BOOL)isLeft{
    UIImageView *fromView = (UIImageView*)[imageViews objectAtIndex:currentIndex];
    UIImageView *toView = (UIImageView*)[imageViews objectAtIndex:index];
    
    if (isLeft) {
        CGRect fromFrame = fromView.frame;
        CGRect toFrame = toView.frame;
        
        toFrame.origin.x = toView.frame.size.width;
        toView.frame = toFrame;
        toFrame.origin.x = 0;
        fromFrame.origin.x = -fromView.frame.size.width;
        
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             [fromView setFrame:fromFrame];
                             [toView setFrame:toFrame];
                         }
                         completion:^(BOOL finished){
                         }];
        [self.slideView addSubview:toView];
    }
    else {
        CGRect fromFrame = fromView.frame;
        CGRect toFrame = toView.frame;
        
        toFrame.origin.x = -toView.frame.size.width;
        toView.frame = toFrame;
        toFrame.origin.x = 0;
        fromFrame.origin.x = fromView.frame.size.width;
        
        
        [UIView animateWithDuration:0.5
                              delay:0
                            options: UIViewAnimationCurveEaseIn
                         animations:^{
                             [fromView setFrame:fromFrame];
                             [toView setFrame:toFrame];
                         }
                         completion:^(BOOL finished){
                         }];
        [self.slideView addSubview:toView];
    }
    
    currentIndex = index;
}

@end
