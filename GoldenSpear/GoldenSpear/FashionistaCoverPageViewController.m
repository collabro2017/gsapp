//
//  FashionistaCoverPageViewController.m
//  GoldenSpear
//
//  Created by JCB on 9/1/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//


#include "FashionistaCoverPageViewController.h"
#include "BaseViewController+TopBarManagement.h"

@interface FashionistaCoverPageViewController()

@end

@implementation FashionistaCoverPageViewController

-(void)viewDidLoad {
    [super viewDidLoad];
}

-(void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapGesture:)];
    [self.containerView addGestureRecognizer:singleTap];
    //[self hidet:YES];
}

-(void)onTapGesture:(UITapGestureRecognizer*)sender {
    
}

- (IBAction)onTapStory:(id)sender {
    _storyVC = [self.storyboard instantiateViewControllerWithIdentifier:@"StoryViewVC"];
    _storyVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    [self presentViewController:_storyVC animated:YES completion:nil];
}

@end
