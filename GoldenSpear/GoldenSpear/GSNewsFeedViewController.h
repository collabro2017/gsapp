//
//  GSNewsFeedViewController.h
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 12/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "GSDoubleDisplayViewController.h"
#import "FullVideoViewController.h"
#import "SearchBaseViewController.h"

#define GSPOST_CELL @"PostCell"

@interface GSNewsFeedViewController : BaseViewController<GSDoubleDisplayDelegate,FullVideoViewDelegate>{
    GSDoubleDisplayViewController* postsDoubleDisplayController;
    NSMutableDictionary* downloadedPosts;
    
    NSMutableArray* downloadQueue;
    BOOL downloadingInQueue;
    BOOL interruptedSearch;
    BOOL finishedDownloading;
    
    NSString* loadingPostInPage;
    
    BOOL cancelOperation;
    
    BOOL isRefreshing;
}

@property (weak, nonatomic) IBOutlet UIView *doubleViewContainer;

@property BOOL bAskingForMoreDataInDoubleDisplay;

- (IBAction)showSuggestedUsers:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *startNewsfeedButton;

@property (nonatomic, strong) NSString * selectedPost;
@property (strong, nonatomic) NSMutableArray* postsArray;
@property (strong, nonatomic) FashionistaPost * selectedPostToDelete;
@property (strong, nonatomic) SearchQuery * currentQuery;

@property User *shownStylist;

- (void)showFullVideo:(NSInteger)orientation;

@end
