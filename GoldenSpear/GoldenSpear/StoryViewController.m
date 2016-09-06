//
//  StoryViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#include "StoryViewController.h"
#include "SlideViewController.h"
#include "ShareViewController.h"


#define ImageStory   1
#define SlideStory   2
#define VideoStory   3

@interface StoryViewController()
@property (weak, nonatomic) IBOutlet UILabel *storyLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *storylabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIView *imageIntroView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageIntroViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *aheadLabel;
@property (weak, nonatomic) IBOutlet UIView *fullCaptionView;
@property (weak, nonatomic) IBOutlet UILabel *fullAheadLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *aheadLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@property (weak, nonatomic) IBOutlet UIView *slideIntroView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *slideIntroViewHeightConstraint;


@property (weak, nonatomic) IBOutlet UILabel *secondStoryLabel;

@end

@implementation StoryViewController {
    NSString *str;
    NSString *aheadStr;
    NSString *secondStr;
    BOOL isHideFullCaption;
    NSInteger storyType;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    str = @"I KNOW WHAT YOUR THINKING. You're thinking that Gigi Hadid, the model who may be the biggest facein fashion right now, can't possibly have much in common with an Olympic decathlete, except for obvious, given that Ashton Eaton is poised to be the face of the 20146 games in Brazil. A few degrees of seperation, however, connect them in a pop-cultural sense. Hadids's fans can recite family trees and point you";
    
    aheadStr = @"Full Speed Ahead \"I'm just more intense than you assume. I'm very competitive.\" says Hadid, putting this Emilio Pucci jumpsuit ($2,850: select Emilio Pucci boutiques), with its long sleeves and graphic color blocking, through its paces. DKNY V-neck dress, $698:select DKNY stores. Stella McCartney earing.";
    
    secondStr = @"For the record, Hadid is pretty excited to meet this world champion. You can see it in her reaction when she grabs a javelin to test her grip, and Eaton offers some tips. \"She has natural ability,\" he announces.";
    
    isHideFullCaption =YES;
    
    [self initView];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
}

-(void)initView {
    _scrollView.delegate = self;
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSRange firstRange = NSMakeRange(0, 1);
    NSRange secondRange = [str rangeOfString:@" KNOW WHAT YOUR THINKING."];
    
    [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:40] range:firstRange];
    [attr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:25] range:secondRange];
    
    _storyLabel.attributedText = attr;
    
    CGSize maximumLabelSize = CGSizeMake(self.view.frame.size.width, FLT_MAX);
    
    CGSize expectedLabelSize = [str sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:30] constrainedToSize:maximumLabelSize lineBreakMode:_storyLabel.lineBreakMode];
    
    _storylabelHeightConstraint.constant = expectedLabelSize.height;
    
    _secondStoryLabel.text = secondStr;
    
    storyType = SlideStory;
    
    if (storyType == ImageStory) {
        _imageIntroView.hidden = NO;
        _imageIntroViewHeightConstraint.constant = [self getViewHeight];
        _slideIntroView.hidden = YES;
        _slideIntroViewHeightConstraint.constant = 0;
        
        _fullCaptionView.clipsToBounds = YES;
        _fullCaptionView.layer.cornerRadius = 10;
        
        NSMutableAttributedString *aheadAttr = [[NSMutableAttributedString alloc] initWithString:aheadStr];
        
        NSRange headRange = [aheadStr rangeOfString:@"Full Speed Ahead"];
        
        [aheadAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Heavy" size:18] range:headRange];
        
        _aheadLabel.attributedText = aheadAttr;
        
        NSMutableAttributedString *fullAheadStr = [[NSMutableAttributedString alloc] initWithString:aheadStr];
        
        [fullAheadStr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"Avenir-Black" size:16] range:headRange];
        
        _fullAheadLabel.attributedText = fullAheadStr;
        
        CGSize aheadLabelExpectedSize = [aheadStr sizeWithFont:[UIFont fontWithName:@"Avenir-Heavy" size:16] constrainedToSize:maximumLabelSize lineBreakMode:_aheadLabel.lineBreakMode];
        
        _aheadLabelHeightConstraint.constant = aheadLabelExpectedSize.height;
        
        _fullCaptionView.hidden = YES;
    }
    else if (storyType == SlideStory) {
        _imageIntroView.hidden = YES;
        _imageIntroViewHeightConstraint.constant = 0;
        _slideIntroView.hidden = NO;
        _slideIntroViewHeightConstraint.constant = [self getViewHeight];
    }
    
    NSLog(@"Scroll View Content Size : %f", _scrollView.contentSize.height);
    NSLog(@"Content View Hiehgt : %f", _containerView.frame.size.height);
}

- (IBAction)showFullCaptionView:(id)sender {
    
    CGRect fromFrame = _fullCaptionView.frame;
    CGRect toFrame = fromFrame;
    fromFrame.origin.x = self.view.frame.size.width;
    _fullCaptionView.frame = fromFrame;
    _fullCaptionView.hidden = NO;
    toFrame.origin.x = 20;
    
    [UIView animateWithDuration:0.6
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         _fullCaptionView.frame = toFrame;
                     }
                     completion:^(BOOL finished){
                         
                     }];
    isHideFullCaption = NO;
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
    isHideFullCaption = YES;
}

- (IBAction)showSlideView:(id)sender {
    SlideViewController *slideVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideViewVC"];
    
    slideVC.isHideFullCaption = isHideFullCaption;
    
    [self presentViewController:slideVC animated:YES completion:nil];
}

-(NSInteger)getViewHeight {
    if (storyType == ImageStory) {
        return 228;
    }
    else if (storyType == SlideStory) {
        return 254;
    }
    else if (storyType == VideoStory) {
        return 0;
    }
    return 0;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    float scrollViewHeight = scrollView.frame.size.height;
    float scrollContentSizeHeight = scrollView.contentSize.height;
    float scrollOffset = scrollView.contentOffset.y;
    
    if (scrollOffset == 0)
    {
        NSLog(@"Scroll End Top");
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else if (scrollOffset + scrollViewHeight >= scrollContentSizeHeight)
    {
        [self showShareView];
    }

}

-(void)showShareView {
    ShareViewController *shareVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ShareViewVC"];
    shareVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:shareVC animated:YES completion:nil];
}

@end
