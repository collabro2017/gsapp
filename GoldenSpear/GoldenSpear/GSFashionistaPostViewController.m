//
//  GSFashionistaPostViewController.m
//  GoldenSpear
//
//  Created by Adria Vernetta Rubio on 10/5/16.
//  Copyright © 2016 GoldenSpear. All rights reserved.
//

#import "GSFashionistaPostViewController.h"
#import "BaseViewController+ActivityFeedbackManagement.h"
#import "BaseViewController+RestServicesManagement.h"
#import "BaseViewController+StoryboardManagement.h"
#import "BaseViewController+TopBarManagement.h"
#import "BaseViewController+BottomControlsManagement.h"
#import "SearchBaseViewController.h"
#import "FashionistaUserListViewController.h"
#import "UILabel+CustomCreation.h"
#import "FullVideoViewController.h"
#import "NYTPhotosViewController.h"
#import "FashionistaProfileViewController.h"

@implementation GSFashionistaPostViewController{
    NSInteger updatingCommentIndex;
    NSInteger commentToDelete;
    
    NSArray* optionHandlers;
    
    BOOL showingOptions;
    
    FashionistaPost* thePost;
    User* postOwner;
    FashionistaContent* theContent;
    
    NSMutableDictionary* commentIndexDict;
    
    BOOL _bComingFromTagsSearch;
    
    NSArray* keywordsAlreadyDownloaded;
    
    BOOL isGETLIKE;
    BOOL searchingPosts;
    NSString *postId;
    
    CMTime currentTime;
    BOOL isSound;
    
    NSMutableArray *searchKeys;
    NSMutableArray *searchStrings;
    NSMutableDictionary *numOfMatches;
    NSInteger currentSearchIndex;
    
}

- (BOOL)shouldCreateHintButton{
    return NO;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    self.contentView.viewDelegate = self;
    self.contentView.postDelegate = self;
    self.optionsView.viewDelegate = self;
    
    currentTime = kCMTimeZero;
    
    thePost = [self.postParameters objectAtIndex:1];
    postOwner = [self.postParameters objectAtIndex:6];
    theContent = [[self.postParameters objectAtIndex:2] firstObject];
    // for statistics, save the search where we come
    if ([self.postParameters count] > 7)
    {
        if ([[self.postParameters objectAtIndex:7] isKindOfClass:[SearchQuery class]])
        {
            [self setSearchQuery:[self.postParameters objectAtIndex:7]];
        }
    }
    
    self.contentView.contentScroll.scrollEnabled = YES;
    
    self.imagesQueue = [[NSOperationQueue alloc] init];
    
    // Set max number of concurrent operations it can perform at 3, which will make things load even faster
    self.imagesQueue.maxConcurrentOperationCount = 3;
    [self setTopBarTitle:postOwner.fashionistaName andSubtitle:postOwner.fashionistaTitle];
    self.optionsViewHeight = [NSLayoutConstraint constraintWithItem:self.optionsView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:nil
                                                          attribute: NSLayoutAttributeNotAnAttribute
                                                         multiplier:1
                                                           constant:46];
    [self.optionsView addConstraint:self.optionsViewHeight];
    [self getContentKeywords];
    [self getUserLikesPost];
    
    // statistics
    [self uploadPostView];
    
    isGETLIKE = NO;
    searchingPosts = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.contentView endDisplayingCell];
}

- (void)getContentKeywords{
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:theContent.idFashionistaContent, nil];
    [self performOwnRestGet:GET_POST_CONTENT_KEYWORDS withParamaters:requestParameters];
}

- (void)getUserLikesPost{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, thePost.idFashionistaPost, nil];
    [self performRestGet:GET_USER_LIKES_POST withParamaters:requestParameters];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self setupData];
}

- (void)setupData{
    [self.contentView prepareForReuse];
    [self.contentView setContentData:self.postParameters currentTime:currentTime hasSound:isSound];
}

- (void)contentView:(GSContentView *)contentView heightChanged:(CGFloat)newHeight reason:(GSPostContentHeightChangeReason)aReason forceResize:(BOOL)forceResize{
    self.contentScroll.contentSize = CGSizeMake(1, newHeight);
}

-(void)setPlayer:(CMTime)videoPlayer hasSound:(BOOL)sound {
    //isRefresh = NO;
    currentTime = videoPlayer;
    isSound = sound;
}
- (void)openFashionistaWithId:(NSString *)userId{
    // Provide feedback to user
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:userId, nil];
    
    [self performRestGet:GET_FASHIONISTA withParamaters:requestParameters];
}

- (void)openFashionistaWithUsername:(NSString *)userName{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADING_ACTV_MSG_", nil)];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:userName, nil];
    
    [self performRestGet:GET_FASHIONISTAWITHNAME withParamaters:requestParameters];
}

- (void)contentPost:(GSContentViewPost *)contentPost doLike:(BOOL)likeOrNot{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        [contentPost setLikeState:!likeOrNot];
        return;
    }
    
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (likeOrNot)
    {
        if (!(self.contentView.thePostId == nil))
        {
            
                if(!([self.contentView.thePostId isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            // Perform request to like post
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            //[self startActivityFeedbackWithMessage:NSLocalizedString(@"_LIKING_USER_MSG_", nil)];
                            
                            // Post the PostLike object
                            
                            NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
                            
                            PostLike *newPostLike = [[PostLike alloc] initWithEntity:[NSEntityDescription entityForName:@"PostLike" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
                            
                            [newPostLike setUserId:appDelegate.currentUser.idUser];
                            
                            [newPostLike setPostId:self.contentView.thePostId];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostLike, nil];
                            
                            [self performRestPost:LIKE_POST withParamaters:requestParameters];
                        }
                    }
                }
        }
    }
    else
    {
        if (!(self.contentView.thePostId == nil))
        {
            
                if(!([self.contentView.thePostId isEqualToString:@""]))
                {
                    if (!(appDelegate.currentUser.idUser == nil))
                    {
                        if(!([appDelegate.currentUser.idUser isEqualToString:@""]))
                        {
                            // Perform request to like post
                            
                            // Provide feedback to user
                            [self stopActivityFeedback];
                            //[self startActivityFeedbackWithMessage:NSLocalizedString(@"_UNLIKING_USER_MSG_", nil)];
                            
                            NSArray * requestParameters = [[NSArray alloc] initWithObjects:appDelegate.currentUser.idUser, self.contentView.thePostId, nil];
                            
                            [self performRestGet:UNLIKE_POST withParamaters:requestParameters];
                        }
                    }
                }
            
        }
    }
}

- (void)getLikeUsers:(GSContentViewPost*)contentPost {
    
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (!(contentPost.thePostId == nil))
    {
        
        if(!([contentPost.thePostId isEqualToString:@""])) {
            NSLog(@"Get Like Users : %@", contentPost.thePostId);
            
            //isGETLIKE = YES;
            
            [self DisplayLikeUser:contentPost.thePostId];
        }
    }
}

-(void)imagePinch:(UIImage*)image {
    NYTExamplePhotoUserProf *selectedPhoto = nil;
    
    NSMutableArray * photos = [[NSMutableArray alloc]init];
    
    NYTExamplePhotoUserProf *photo = [[NYTExamplePhotoUserProf alloc] init];
    
    if(image == nil)
    {
        image = [UIImage imageNamed:@"portrait.png"];
    }
    
    photo.image = image;
    
    selectedPhoto = photo;
    
    [photos addObject:photo];
    
    NYTPhotosViewController *photosViewController = [[NYTPhotosViewController alloc] initWithPhotos:photos initialPhoto:selectedPhoto];
    [self presentViewController:photosViewController animated:YES completion:nil];
    
    return;

}

- (void)DisplayLikeUser:(NSString*)postid {
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: postid, nil];
    
    searchingPosts = NO;
    postId = postid;
    //_shownStylist = user;
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    [self performRestGet:PERFORM_SEARCH_WITHIN_FASHIONISTAS_LIKE_POST withParamaters:requestParameters];
}

- (void)processUserListAnswer:(NSArray*)mappingResult andConnection:(connectionType)connection{
    // Paramters for next VC (ResultsViewController)
    searchingPosts = YES;
    NSArray * parametersForNextVC = [NSArray arrayWithObjects: mappingResult, [NSNumber numberWithInt:connection], nil];
    
    [self stopActivityFeedback];
    
    if ([mappingResult count] > 0)
    {
        UIStoryboard *nextStoryboard = [UIStoryboard storyboardWithName:@"Search" bundle:nil];
        BaseViewController *nextViewController = [nextStoryboard instantiateViewControllerWithIdentifier:[@(USERLIST_VC) stringValue]];
        
        [self prepareViewController:nextViewController withParameters:parametersForNextVC];
        [(SearchBaseViewController*)nextViewController setSearchContext:FASHIONISTAS_LIKE];
        [self showViewControllerModal:nextViewController];
        ((FashionistaUserListViewController*)nextViewController).shownRelatedUser = _shownStylist;
        ((FashionistaUserListViewController*)nextViewController).userListMode = LIKEUSERS;
        ((FashionistaUserListViewController*)nextViewController).postId = thePost.idFashionistaPost;
        [self setTitleForModal:@"LIKES"];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_FOLLOWERSORFOLLOWING_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
    }
}


- (void)actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *)mappingResult{
    __block User * currentUser;
    
    NSArray * parametersForNextVC;
    NSManagedObjectContext *currentContext;
    Wardrobe *_wardrobeSelected = nil;
    
    __block SearchQuery *searchQuery;
    NSMutableArray *foundResults = [[NSMutableArray alloc] init];
    NSMutableArray *foundResultsGroups = [[NSMutableArray alloc] init];
    NSMutableArray *successfulTerms = nil;
    __block NSString * notSuccessfulTerms = @"";
    
    switch (connection)
    {
        case FINISHED_SEARCH_WITHOUT_RESULTS:
        {
            [self stopActivityFeedback];
            
            if(_bComingFromTagsSearch == YES)
            {
                _bComingFromTagsSearch = NO;
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_KEYWORD_CONTENT_RELATED_FOUND_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
            }else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_RESULTS_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                
                [alertView show];
            }
            break;
        }
        case FINISHED_SEARCH_WITH_RESULTS:
        {
            // Get the number of total results that were provided
            // and the string of terms that didn't provide any results
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[SearchQuery class]]))
                 {
                     searchQuery = obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            if (searchQuery.numresults > 0) {
                if (!searchingPosts) {
                    [self stopActivityFeedback];
                    [self processUserListAnswer:mappingResult andConnection:connection];
                    break;
                }
            }
            
            if (searchQuery.numresults > 0)
            {
                
                // Get the list of results groups that were provided
                for (ResultsGroup *group in mappingResult)
                {
                    if([group isKindOfClass:[ResultsGroup class]])
                    {
                        if(!(group.idResultsGroup == nil))
                        {
                            if (!([group.idResultsGroup isEqualToString:@""]))
                            {
                                if(!([foundResultsGroups containsObject:group]))
                                {
                                    [foundResultsGroups addObject:group];
                                }
                            }
                        }
                    }
                }
                
                // Get the list of results that were provided
                for (GSBaseElement *result in mappingResult)
                {
                    if([result isKindOfClass:[GSBaseElement class]])
                    {
                        if(!(result.idGSBaseElement == nil))
                        {
                            if (!([result.idGSBaseElement isEqualToString:@""]))
                            {
                                if(!([foundResults containsObject:result.idGSBaseElement]))
                                {
                                    [foundResults addObject:result.idGSBaseElement];
                                }
                            }
                        }
                    }
                }
                
                // Get the keywords that provided results
                for (Keyword *keyword in mappingResult)
                {
                    if([keyword isKindOfClass:[Keyword class]])
                    {
                        if (successfulTerms == nil)
                        {
                            successfulTerms = [[NSMutableArray alloc] init];
                        }
                        
                        if(!(keyword.name == nil))
                        {
                            if (!([keyword.name isEqualToString:@""]))
                            {
                                NSString * pene = [[keyword.name lowercaseString] capitalizedString];
                                pene = [pene stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                
                                if (!([successfulTerms containsObject:pene]))
                                {
                                    // Add the term to the set of terms
                                    [successfulTerms addObject:pene];
                                }
                            }
                        }
                        
                    }
                }
                
                
                if(_bComingFromTagsSearch == YES)
                {
                    // Paramters for next VC (ResultsViewController)
                    NSNumber *bFromTagSearch = [NSNumber numberWithBool:YES];
                    UIImage *image = ((GSImageTaggableView*)self.contentView.taggableView).imageView.image;
                    NSArray * parametersForNextVC = [NSArray arrayWithObjects: searchQuery, foundResults, foundResultsGroups, successfulTerms, notSuccessfulTerms, bFromTagSearch, image, nil];
                    
                    _bComingFromTagsSearch = NO;
                    
                    [self stopActivityFeedback];
                    
                    if ([foundResults count] > 0)
                    {
                        [self transitionToViewController:SEARCH_VC withParameters:parametersForNextVC];
                    }
                    else
                    {
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_KEYWORD_CONTENT_RELATED_FOUND_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                        
                        [alertView show];
                        
                    }
                }
                else
                {
                    
                }
            }
            else
            {
                if(_bComingFromTagsSearch == YES)
                {
                    _bComingFromTagsSearch = NO;
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_KEYWORD_CONTENT_RELATED_FOUND_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_NO_FOLLOWERSORFOLLOWING_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
                    
                    [alertView show];
                }
            }
            
            break;
        }
        case PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS:
        {
            for (SearchQuery *query in mappingResult) {
                if ([query isKindOfClass:[SearchQuery class]]) {
                    NSLog(@"Numers of Matches : %i", query.numresults.intValue);
                    [numOfMatches setObject:query.numresults forKey:[searchKeys objectAtIndex:currentSearchIndex]];
                    if (currentSearchIndex < [searchKeys count] - 1) {
                        currentSearchIndex ++;
                        NSArray * requestParameters = [NSArray arrayWithObjects:(NSString*)[searchStrings objectAtIndex:currentSearchIndex], nil];
                        [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS withParamaters:requestParameters];
                    }
                    else {
                        [self stopActivityFeedback];
                        [self.contentView.taggableView setNumOfMatches:numOfMatches];
                    }
                }
            }
            break;
        }
        case GET_WARDROBE:
        {
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (Wardrobe *item in mappingResult)
            {
                if([item isKindOfClass:[Wardrobe class]])
                {
                    if(!(item.idWardrobe== nil))
                    {
                        if(!([item.idWardrobe isEqualToString:@""]))
                        {
                            _wardrobeSelected = item;
                            break;
                        }
                    }
                }
            }
            
            [_wardrobeSelected.itemsId removeAllObjects];
            
            // Get the list of items that were provided to fill the Wardrobe.itemsId property
            for (GSBaseElement *item in mappingResult)
            {
                if([item isKindOfClass:[GSBaseElement class]])
                {
                    if(!(item.idGSBaseElement== nil))
                    {
                        if(!([item.idGSBaseElement isEqualToString:@""]))
                        {
                            if(_wardrobeSelected.itemsId == nil)
                            {
                                _wardrobeSelected.itemsId = [[NSMutableArray alloc] init];
                            }
                            
                            if(!([_wardrobeSelected.itemsId containsObject:item.idGSBaseElement]))
                            {
                                [_wardrobeSelected.itemsId addObject:item.idGSBaseElement];
                            }
                        }
                    }
                }
            }
            
            // Paramters for next VC (ResultsViewController)
            parametersForNextVC = [NSArray arrayWithObjects:_wardrobeSelected, [NSNumber numberWithBool:FALSE], nil];
            [self stopActivityFeedback];
            
            [self transitionToViewController:WARDROBECONTENT_VC withParameters:parametersForNextVC];
            break;
        }
        case UPLOAD_SHARE:
        {
            // Get the list of comments that were provided
            for (Share *newShare in mappingResult)
            {
                if([newShare isKindOfClass:[Share class]])
                {
                    [self socialShareActionWithShareObject:((Share*) newShare) andPreviewImage:[UIImage cachedImageWithURL:self.contentView.preview_image]];
                    
                    break;
                }
            }
            break;
        }
        case GET_FASHIONISTAWITHNAME:
        case GET_FASHIONISTA:
        {
            // Get the product that was provided
            [mappingResult enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                 if (([obj isKindOfClass:[User class]]))
                 {
                     currentUser = (User *)obj;
                     
                     // Stop the enumeration
                     *stop = YES;
                 }
             }];
            
            
            
            if(currentUser){
                
                if (isGETLIKE) {
                    [self DisplayLikeUser:currentUser];
                    [self stopActivityFeedback];
                    isGETLIKE = NO;
                    break;
                }
                // Paramters for next VC (ResultsViewController)
                parametersForNextVC = [NSArray arrayWithObjects: /*_selectedResult, */currentUser, [NSNumber numberWithBool:NO], nil];
                [self transitionToViewController:USERPROFILE_VC withParameters:parametersForNextVC];
            }
            [self stopActivityFeedback];
            
            
            
            break;
        }
        case GET_USER_LIKES_POST:
        {
            BOOL _currentUserLikesPost = NO;
            for (NSMutableDictionary *userLikesPostDict in mappingResult)
            {
                if([userLikesPostDict isKindOfClass:[NSMutableDictionary class]])
                {
                    NSNumber * like = [userLikesPostDict objectForKey:@"like"];
                    
                    _currentUserLikesPost = (like.intValue > 0);
                }
            }
            [self.contentView setLikeState:_currentUserLikesPost];
            break;
        }
        case GET_ONLYPOST_LIKES_NUMBER:
        {
            NSNumber* _postLikesNumber;
            // Get the list of comments that were provided
            for (NSMutableDictionary *postLikesNumberDict in mappingResult)
            {
                if([postLikesNumberDict isKindOfClass:[NSMutableDictionary class]])
                {
                    _postLikesNumber = [postLikesNumberDict objectForKey:@"likes"];
                }
            }
            [self.contentView setLikesNumber:[_postLikesNumber integerValue]];
            break;
        }
        case LIKE_POST:
        case UNLIKE_POST:
        {
            /*
            BOOL _currentUserLikesPost = ((connection == LIKE_POST) ? (YES) : (NO));
            
            [self.contentView setLikeState:_currentUserLikesPost];
             */
            // Reload Post Likes
            
            if(!(self.contentView.thePostId == nil))
            {
                if(!([self.contentView.thePostId isEqualToString:@""]))
                {
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:self.contentView.thePostId, nil];
                    
                    [self performRestGet:GET_ONLYPOST_LIKES_NUMBER withParamaters:requestParameters];
                }
            }
            
            [self stopActivityFeedback];
            break;
        }
        case GET_USER:
        {
            //Maybe re-layout post content
            break;
        }
        case ADD_COMMENT_TO_POST:
        {
            Comment * uploadedComment = nil;
            
            // Get the Added comment
            for (Comment * content in mappingResult)
            {
                if([content isKindOfClass:[Comment class]])
                {
                    if(!(content.idComment == nil))
                    {
                        if  (!([content.idComment isEqualToString:@""]))
                        {
                            uploadedComment = content;
                            break;
                        }
                    }
                }
            }
            
            NSMutableArray* newParameters = [NSMutableArray arrayWithArray:self.postParameters];
            NSMutableArray* commentArray = [NSMutableArray arrayWithArray:[newParameters objectAtIndex:3]];
            if(updatingCommentIndex>=0){
                [commentArray replaceObjectAtIndex:updatingCommentIndex withObject:uploadedComment];
                
                updatingCommentIndex = -1;
            }else{
                [self.contentView addCommentObject:uploadedComment];
                [commentArray addObject:uploadedComment];
            }
            [newParameters replaceObjectAtIndex:3 withObject:commentArray];
            self.postParameters = newParameters;
            
            [self setupData];
            [self stopActivityFeedback];
            
            [self closeWriteComment];
            
            break;
        }
        case DELETE_POST:
        {
            currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
            
            //[currentContext deleteObject:self.contentView.thePost];
            //Implementar DELETE con Id del post
            
            [currentContext processPendingChanges];
            
            if (![currentContext save:nil])
            {
                NSLog(@"Save did not complete successfully.");
            }
            
            [self stopActivityFeedback];
            
            //Go Back
            [self swipeRightAction];
            break;
        }
        case DELETE_COMMENT:
        {
            if(commentToDelete>=0){
                NSMutableArray* newParameters = [NSMutableArray arrayWithArray:self.postParameters];
                NSMutableArray* commentArray = [NSMutableArray arrayWithArray:[newParameters objectAtIndex:3]];
                [commentArray removeObjectAtIndex:commentToDelete];
                [newParameters replaceObjectAtIndex:3 withObject:commentArray];
                for (NSInteger i = commentToDelete; i<[commentArray count]; i++) {
                    Comment* c = [commentArray objectAtIndex:i];
                    [commentIndexDict setValue:[NSNumber numberWithInteger:i] forKey:c.idComment];
                }
                self.postParameters = newParameters;
                
                [self setupData];
                commentToDelete = -1;
            }
            [self stopActivityFeedback];
            
            break;
        }
        case GET_POST_CONTENT_KEYWORDS:
        {
            NSMutableArray* keyWordsGathered = [NSMutableArray new];
            // Get the post that was provided
            for (NSString *fashionistaContentId in mappingResult)
            {
                if([fashionistaContentId isKindOfClass:[NSString class]])
                {
                    // Get the keywords that were provided
                    for (KeywordFashionistaContent *keywordFashionista in mappingResult)
                    {
                        if([keywordFashionista isKindOfClass:[KeywordFashionistaContent class]])
                        {
                            [keyWordsGathered addObject:keywordFashionista];
                        }
                    }
                }
            }
            [self.contentView.taggableView addTags:keyWordsGathered];
            break;
        }
        case POST_FOLLOW:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unfollowedPosts removeObjectForKey:self.contentView.thePostId];
            break;
        }
        case POST_UNFOLLOW:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unfollowedPosts setObject:[mappingResult firstObject] forKey:self.contentView.thePostId];
            break;
        }
        case POST_NO_NOTICES:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unnoticedPosts setObject:[mappingResult firstObject] forKey:self.contentView.thePostId];
            break;
        }
        case POST_YES_NOTICES:
        {
            [((AppDelegate*)[UIApplication sharedApplication].delegate).currentUser.unnoticedPosts removeObjectForKey:self.contentView.thePostId];
            break;
        }
        default:
            break;
    }
}

- (void)titleButtonAction:(UIButton *)sender{
    [self openFashionistaWithUsername:self.contentView.postOwner_name];
}

- (void) performOwnRestGet:(connectionType)connection withParamaters:(NSArray *)parameters
{
    NSString * requestString;
    NSArray * dataClasses;
    NSArray *failedAnswerErrorMessage;
    NSString * currentFashionistaContentId = nil;
    
    switch (connection)
    {
        case GET_POST_CONTENT_KEYWORDS:
        {
            if(!(parameters == nil))
            {
                if ([parameters count] == 1)
                {
                    currentFashionistaContentId = ((NSString *)([parameters objectAtIndex:0]));
                    
                    // 0 = Post
                    // String to perform the request
                    //requestString = [NSString stringWithFormat:@"/fashionistaPostContent/%@/keywords?limit=-1&populate=keyword_fashionistaPostContents",((NSString *)([parameters objectAtIndex:0]))];
                    requestString = [NSString stringWithFormat:@"/fashionistapostcontent_keywords__keyword_fashionistapostcontents?fashionistapostcontent_keywords=%@&limit=-1&populate=keyword_fashionistaPostContents",((NSString *)([parameters objectAtIndex:0]))];
                    
                    //Data classes to look for
                    dataClasses = [NSArray arrayWithObjects:[KeywordFashionistaContent class], nil];
                    
                    //Message to show if no results were provided
                    failedAnswerErrorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_NO_CONTENTS_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                }
                else
                {
                    NSLog(@"XXXX Incorrect number of parameters to perform GET_POST_CONTENT_KEYWORDS request! XXXX");
                    
                    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
                    
                    return;
                }
            }
            
            break;
        }
            
        default:
            break;
    }
    
    if(!(requestString == nil) && (!(dataClasses == nil)))
    {
        if ((!([requestString isEqualToString:@""])) && ([dataClasses count] > 0))
        {
            NSDate *methodStart = [NSDate date];
            
            [[RKObjectManager sharedManager] getObjectsAtPath:requestString
                                                   parameters:nil
                                                      success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult)
             {
                 // If the GS server provided an answer, check wheter that answer could be mapped into our data classes
                 
                 NSDate *methodFinish = [NSDate date];
                 
                 NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                 
                 NSLog(@"Operation <%@> succeed!! It took: %f", operation.HTTPRequestOperation.request.URL, executionTime);
                 
                 NSArray *mappedResults = [mappingResult array];
                 
                 
                 switch (connection)
                 {
                     case GET_POST_CONTENT_KEYWORDS:
                     {
                         NSMutableArray* keyWordsGathered = [NSMutableArray new];
                         // Get the keywords that were provided
                         for (KeywordFashionistaContent *keywordFashionista in mappedResults)
                         {
                             if([keywordFashionista isKindOfClass:[KeywordFashionistaContent class]])
                             {
                                 if (keywordFashionista.keyword != nil)
                                 {
                                     Keyword * keyword = keywordFashionista.keyword;
                                     if(!(keyword.idKeyword == nil))
                                     {
                                         if  (!([keyword.idKeyword isEqualToString:@""]))
                                         {
                                             [keyWordsGathered addObject:keywordFashionista];
                                         }
                                     }
                                 }
                             }
                         }
                         
                         [self.contentView.taggableView addTags:keyWordsGathered];
                         keywordsAlreadyDownloaded = [NSArray arrayWithArray:keyWordsGathered];
                         break;
                     }
                     default:
                         break;
                 }
             }
                                                      failure:^(RKObjectRequestOperation *operation, NSError *error)
             {
                 //Message to show if no results were provided
                 NSArray *errorMessage = [NSArray arrayWithObjects:NSLocalizedString(@"_ERROR_", nil), NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil), NSLocalizedString(@"_OK_", nil), nil];
                 
                 // If 'failedAnswerErrorMessage' is nil, it means that we don't want to provide messages to the user
                 if(failedAnswerErrorMessage == nil)
                 {
                     errorMessage = nil;
                 }
                 
                 NSLog(@"Operation <%@> failed with error: %ld", operation.HTTPRequestOperation.request.URL, (long)operation.HTTPRequestOperation.response.statusCode);
                 
                 [self processRestConnection: connection WithErrorMessage:errorMessage forOperation:operation];
             }];
            
            return;
        }
    }
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_ERROR_", nil) message:NSLocalizedString(@"_CONNECTION_ERROR_MSG_", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
    
    [alertView show];
    
    
    [self processRestConnection: connection WithErrorMessage:nil forOperation:nil];
}

#pragma mark - Comments

- (void)showCommentView:(NSInteger)index withOldComment:(Comment*)comment{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FashionistaContents" bundle:[NSBundle mainBundle]];
    FashionistaAddCommentViewController* theVC = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",ADDCOMMENT_VC]];
    theVC.commentDelegate = self;
    theVC.oldComment = comment;
    [self showViewControllerModal:theVC];
    if(theVC.oldComment){
        theVC.commentIndex = index;
        [theVC setTitleForModal:@"EDIT COMMENT"];
    }
}

- (void)searchForKeywords:(NSArray *)searchTerms{
    if([searchTerms count] > 0&&!_bComingFromTagsSearch)
    {
        //Setup search string
        
        NSString *stringToSearch = [self composeStringhWithTermsOfArray:searchTerms encoding:YES];
        
        // Check that the final string to search is valid
        if (((stringToSearch == nil) || ([stringToSearch isEqualToString:@""])))
        {
            return;
        }
        else
        {
            _bComingFromTagsSearch = YES;
            NSLog(@"Performing search with terms: %@", stringToSearch);
            
            // Provide feedback to user
            [self stopActivityFeedback];
            [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
            
            NSArray * requestParameters = [NSArray arrayWithObject:stringToSearch];
            [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS withParamaters:requestParameters];
        }
    }
}

-(void)getNumberOfMatchs:(NSMutableDictionary *)searchDictionary {
    [searchKeys removeAllObjects];
    searchKeys = [NSMutableArray new];
    [searchStrings removeAllObjects];
    searchStrings = [NSMutableArray new];
    [numOfMatches removeAllObjects];
    numOfMatches = [NSMutableDictionary new];
    currentSearchIndex = 0;
    
    NSArray *keys = [searchDictionary allKeys];
    for (NSNumber *key in keys) {
        
        NSArray *keywordsArray = [NSArray arrayWithArray:[searchDictionary objectForKey:key]];
        if ([keywordsArray count] > 0) {
            NSString *stringToSearch = [self composeStringhWithTermsOfArray:keywordsArray encoding:YES];
            
            if ((stringToSearch == nil) || ([stringToSearch isEqualToString:@""])) {
                return;
            }
            else {
                
                [searchKeys addObject:key];
                [searchStrings addObject:stringToSearch];
                
                NSLog(@"Number of Matches : %@", stringToSearch);
            }
        }
    }
    
    if ([searchStrings count] > 0) {
        [self stopActivityFeedback];
        [self startActivityFeedbackWithMessage:NSLocalizedString(@"_SEARCHING_ACTV_MSG_", nil)];
        
        NSArray * requestParameters = [NSArray arrayWithObjects:(NSString*)[searchStrings objectAtIndex:0], nil];
        [self performRestGet:PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS withParamaters:requestParameters];
    }
}

- (void)openWardrobeWithId:(NSString *)wardrobeId{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_DOWNLOADINGCONTENT_ACTV_MSG_", nil)];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:wardrobeId, nil];
    
    [self performRestGet:GET_WARDROBE withParamaters:requestParameters];
}

- (void)commentContentPost:(GSContentViewPost *)contentPost atIndex:(NSInteger)index{
    AppDelegate *appDelegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if (!appDelegate.completeUser) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_PROFILE_COMPLETE_ERROR_",nil)
                                                        message:NSLocalizedString(@"_PROFILE_COMPLETE_MSG",nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"_OK_",nil)
                                              otherButtonTitles:nil];
        [alert show];
        return;
    }
    [self showCommentView:index withOldComment:contentPost.editingComment];
}

- (void)updateNewComment:(Comment *)theComment{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    
    [theComment setFashionistaPostId:self.contentView.thePostId];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: self.contentView.thePostId, theComment, nil];
    updatingCommentIndex = -1;
    [self performRestPost:ADD_COMMENT_TO_POST withParamaters:requestParameters];
}

- (void)updateOldComment:(Comment *)theComment atIndex:(NSInteger)index{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    
    [theComment setFashionistaPostId:self.contentView.thePostId];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: self.contentView.thePostId, theComment,[NSNumber numberWithBool:YES], nil];
    updatingCommentIndex = [[commentIndexDict objectForKey:theComment.idComment] integerValue];
    [self performRestPost:ADD_COMMENT_TO_POST withParamaters:requestParameters];
}

- (void)contentPost:(GSContentViewPost *)contentPost deleteComment:(Comment *)theComment atIndex:(NSInteger)commentIndex{
    [self stopActivityFeedback];
    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGCOMMENT_ACTV_MSG_", nil)];
    
    commentToDelete = [[commentIndexDict objectForKey:theComment.idComment] integerValue];
    NSArray * requestParameters = [[NSArray alloc] initWithObjects: self.contentView.thePostId, theComment, nil];
    [self performRestDelete:DELETE_COMMENT withParamaters:requestParameters];
}

- (void)closeWriteComment
{
    [self dismissControllerModal];
    [self.contentView.commentsTableView reloadData];
}

#pragma mark -

- (void)deletePost:(GSContentViewPost*)contentPost{
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:self.contentView.thePostId, nil];
    [self performRestDelete:DELETE_POST withParamaters:requestParameters];
}

- (void)startEditMode:(GSContentViewPost*)contentPost{
    [self setEditMode:contentPost withMode:YES];
}

- (void)setEditMode:(GSContentViewPost*)contentPost withMode:(BOOL)editMode{
    [contentPost setEditMode:editMode];
}

- (void)sharePost:(GSContentViewPost*)contentPost{
    NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
    
    Share * newShare = [[Share alloc] initWithEntity:[NSEntityDescription entityForName:@"Share" inManagedObjectContext:currentContext] insertIntoManagedObjectContext:currentContext];
    
    [newShare setSharedPostId:contentPost.thePostId];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (!(appDelegate.currentUser == nil))
    {
        if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            [newShare setSharingUserId:appDelegate.currentUser.idUser];
        }
    }
    
    [currentContext processPendingChanges];
    
    [currentContext save:nil];
    
    NSArray * requestParameters = [[NSArray alloc] initWithObjects:newShare, nil];
    
    [self performRestPost:UPLOAD_SHARE withParamaters:requestParameters];
}

- (void)saveImage:(GSContentViewPost*)contentPost{
    UIImageWriteToSavedPhotosAlbum(((GSImageTaggableView*)self.contentView.taggableView).imageView.image, nil, nil, nil);
    UIAlertView* anAlert = [[UIAlertView alloc] initWithTitle:@"Save Image"
                                                      message:@"Image saved succesfully"
                                                     delegate:nil
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
    [anAlert show];
}

- (void)flagPost:(GSContentViewPost*)contentPost{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ((appDelegate.currentUser == nil))
    {
        // Must be logged!
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_INFO_", nil) message:NSLocalizedString(@"_MUSTBELOGGED_MSG_", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"_OK_", nil) otherButtonTitles:nil];
        
        [alertView show];
        
        return;
    }
    
    // Here we need to pass a full frame
    CustomAlertView *alertView = [[CustomAlertView alloc] init];
    
    UIView *errorTypesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 220)];
    
    for (int i = 0; i < maxPostContentReportTypes; i++)
    {
        NSString *postContentReportType = [NSString stringWithFormat:@"_POSTCONTENT_REPORT_TYPE_%i_", i];
        
        UILabel *reportTypeLabel = [UILabel createLabelWithOrigin:CGPointMake(10, (10 * (i+1)) + (30 * i))
                                                          andSize:CGSizeMake(errorTypesView.frame.size.width - 80, 30)
                                               andBackgroundColor:[UIColor clearColor]
                                                         andAlpha:1.0
                                                          andText:NSLocalizedString(postContentReportType, nil)
                                                     andTextColor:[UIColor blackColor]
                                                          andFont:[UIFont fontWithName:@"Avenir-Light" size:15]
                                                   andUppercasing:NO
                                                       andAligned:NSTextAlignmentLeft];
        
        UISwitch *switchErrorType = [[UISwitch alloc] initWithFrame:CGRectMake(reportTypeLabel.frame.origin.x + reportTypeLabel.frame.size.width + 10, reportTypeLabel.frame.origin.y, 80, 10)];
        [switchErrorType setTag:i];
        [switchErrorType setOn:NO animated:NO];
        
        [errorTypesView addSubview:reportTypeLabel];
        [errorTypesView addSubview:switchErrorType];
    }
    
    // Add some custom content to the alert view
    [alertView setContainerView:errorTypesView];
    
    // Modify the parameters
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"_CANCEL_", nil), NSLocalizedString(@"_SEND_", nil), nil]];
    
    [alertView setDelegate:self];
    
    [alertView setUseMotionEffects:true];
    
    // You may use a Block, rather than a delegate.
    [alertView setOnButtonTouchUpInside:^(CustomAlertView *alertView, int buttonIndex) {
        
        if(buttonIndex == 1)
        {
            // Check that the name is valid
            
            if (!(self.contentView.thePostId == nil))
            {
                if(!([self.contentView.thePostId isEqualToString:@""]))
                {
                    // Post the PostContentReport object
                    
                    PostContentReport * newPostContentReport = [[PostContentReport alloc] init];
                    
                    [newPostContentReport setPostId:self.contentView.thePostId];
                    
                    int reportType = 0;
                    
                    for (UIView * view in alertView.containerView.subviews)
                    {
                        if ([view isKindOfClass:[UISwitch class]])
                        {
                            reportType += ((pow(2,(view.tag))) * ([((UISwitch*) view) isOn]));
                        }
                    }
                    
                    [newPostContentReport setReportType:[NSNumber numberWithInt:reportType]];
                    
                    
                    if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                    {
                        [newPostContentReport setUserId:appDelegate.currentUser.idUser];
                    }
                    
                    NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostContentReport, nil];
                    
                    [self stopActivityFeedback];
                    [self startActivityFeedbackWithMessage:NSLocalizedString(@"_UPLOADINGPOSTCONTENTREPORT_ACTV_MSG_", nil)];
                    
                    [self performRestPost:ADD_POSTCONTENTREPORT withParamaters:requestParameters];
                }
            }
        }
        [alertView close];
        
    }];
    
    // And launch the dialog
    [alertView show];
}

- (void)customAlertViewButtonTouchUpInside:(id)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Delegate: Button at position %d is clicked on alertView %d.", (int)buttonIndex, (int)[alertView tag]);
}

- (void)switchNotifications:(GSContentViewPost*)contentPost{
    //New operation for switching on/off notifications for post
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostUserUnfollow* unfollow = [appDelegate.currentUser.unnoticedPosts objectForKey:self.contentView.thePostId];
    if(unfollow){
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        [self performRestDelete:POST_YES_NOTICES withParamaters:requestParameters];
    }else{
        unfollow = [PostUserUnfollow new];
        unfollow.userId = appDelegate.currentUser.idUser;
        unfollow.postId = contentPost.thePostId;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        
        [self performRestPost:POST_NO_NOTICES withParamaters:requestParameters];
    }
}

- (void)unfollowImage:(GSContentViewPost*)contentPost{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    PostUserUnfollow* unfollow = [appDelegate.currentUser.unfollowedPosts objectForKey:self.contentView.thePostId];
    if(unfollow){
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        [self performRestDelete:POST_FOLLOW withParamaters:requestParameters];
    }else{
        unfollow = [PostUserUnfollow new];
        unfollow.userId = appDelegate.currentUser.idUser;
        unfollow.postId = contentPost.thePostId;
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:unfollow, nil];
        [self performRestPost:POST_UNFOLLOW withParamaters:requestParameters];
    }
}

- (void)expandComments:(GSContentViewPost *)contentPost{
    //[postCellExpanded setObject:[NSNumber numberWithInt:1] forKey:contentPost.thePost.idFashionistaPost];
}

- (void)configOptions{
    NSMutableArray* optionsArray = [NSMutableArray new];
    NSMutableArray* handlersArray = [NSMutableArray new];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //DELETE
    if (appDelegate.currentUser.name==self.contentView.postOwner_name){
        [optionsArray addObject:@"DELETE"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(deletePost:)]];
    }
    //EDIT
    if ([self.contentView hasOwnComments]){
        [optionsArray addObject:@"EDIT COMMENTS"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(startEditMode:)]];
    }
    //SHARE
    {
        [optionsArray addObject:@"SHARE"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(sharePost:)]];
    }
    //UNFOLLOW IMAGE
    if (appDelegate.currentUser.name!=self.contentView.postOwner_name&&self.contentView.isFollowingOwner){
        NSString* optionString = @"UNFOLLOW IMAGE";
        if ([appDelegate.currentUser.unfollowedPosts objectForKey:self.contentView.thePostId]) {
            optionString = @"FOLLOW IMAGE";
        }
        [optionsArray addObject:optionString];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(unfollowImage:)]];
    }
    //SAVE IMAGE
    {
        [optionsArray addObject:@"SAVE IMAGE"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(saveImage:)]];
    }
    //FLAG
    if (appDelegate.currentUser.name!=self.contentView.postOwner_name){
        [optionsArray addObject:@"FLAG"];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(flagPost:)]];
    }
    //TURN ON NOTIFICATIONS
    {
        NSString* optionString = @"TURN OFF NOTIFICATIONS";
        if ([appDelegate.currentUser.unnoticedPosts objectForKey:self.contentView.thePostId]) {
            optionString = @"TURN ON NOTIFICATIONS";
        }
        [optionsArray addObject:optionString];
        [handlersArray addObject:[NSValue valueWithPointer:@selector(switchNotifications:)]];
    }
    
    optionHandlers = [NSArray arrayWithArray:handlersArray];
    [self.optionsView setOptions:optionsArray];
    [self.optionsView layoutIfNeeded];
}

- (void)optionsView:(GSOptionsView *)optionView selectOptionAtIndex:(NSInteger)option{
    if ([optionHandlers count]>option) {
        SEL retriveSelector = [[optionHandlers objectAtIndex:option] pointerValue];
        [self performSelector:retriveSelector withObject:self.contentView];
    }
    [self closeOptions:nil];
}

- (void)optionsView:(GSOptionsView *)optionView heightChanged:(CGFloat)newHeight{
    self.optionsViewHeight.constant = newHeight;
    [self.optionsView layoutIfNeeded];
}

- (void)openOptionsForContent:(GSContentViewPost *)contentPost atWindowPoint:(CGPoint)anchor{
    [self configOptions];
    CGPoint viewPoint = CGPointZero;
    if(!showingOptions){
        [self.optionsView showUpToDown:YES];
        //Check if it fits screen or show it downToUp
        viewPoint = [self.optionsBackground convertPoint:anchor fromView:[UIApplication sharedApplication].keyWindow];
        CGFloat optionsHeight = self.optionsView.frame.size.height;
        CGFloat superHeight = [UIScreen mainScreen].bounds.size.height-88;
        if((anchor.y+optionsHeight>superHeight)){
            [self.optionsView showUpToDown:NO];
            optionsHeight = self.optionsView.frame.size.height;
            viewPoint.y -= 10 + optionsHeight;
        }else{
            viewPoint.y += 10;
            [self.optionsView showUpToDown:YES];
        }
    }
    [self showOptions:!showingOptions fromPoint:viewPoint];
}

- (void)showOptions:(BOOL)showOrNot fromPoint:(CGPoint)anchor{
    showingOptions = showOrNot;
    
    if (showOrNot) {
        self.optionsBackground.alpha = 1;
        self.optionsViewTop.constant = anchor.y;
        [self.optionsView moveAngleToPosition:anchor.x];
        [self.optionsView layoutIfNeeded];
        
        [self.optionsBackground.superview bringSubviewToFront:self.optionsBackground];
    }else{
        [self.optionsBackground.superview sendSubviewToBack:self.optionsBackground];
        self.optionsBackground.alpha = 0;
    }
}

- (IBAction)closeOptions:(id)sender {
    if(showingOptions){
        [self showOptions:NO fromPoint:CGPointZero];
    }
}

- (void)contentView:(GSContentView *)contentView downloadContentImage:(NSString *)imageURL{
    if ([UIImage isCached:imageURL])
    {
        UIImage * image = [UIImage cachedImageWithURL:imageURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        [self.contentView setPostImage];
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:imageURL];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.contentView setPostImage];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
}

- (void)contentView:(GSContentView *)contentView downloadProfileImage:(NSString *)imageURL{
    if ([UIImage isCached:imageURL])
    {
        UIImage * image = [UIImage cachedImageWithURL:imageURL];
        
        if(image == nil)
        {
            image = [UIImage imageNamed:@"no_image.png"];
        }
        
        [self.contentView setProfileImage];
    }
    else
    {
        NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
            
            UIImage * image = [UIImage cachedImageWithURL:imageURL];
            
            if(image == nil)
            {
                image = [UIImage imageNamed:@"no_image.png"];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.contentView setProfileImage];
            });
        }];
        
        operation.queuePriority = NSOperationQueuePriorityHigh;
        
        [self.imagesQueue addOperation:operation];
    }
}

- (void)contentPost:(GSContentViewPost*)contentPost showComments:(NSArray*)comments withEditMode:(BOOL)editOrNot{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"FashionistaContents" bundle:[NSBundle mainBundle]];
    GSCommentViewController* theVC = [storyBoard instantiateViewControllerWithIdentifier:[NSString stringWithFormat:@"%d",COMMENTS_VC]];
    theVC.commentDelegate = self;
    theVC.commentArray = comments;
    theVC.shouldEdit = editOrNot;
    [self showViewControllerModal:theVC];
}

- (void)contentPost:(GSContentViewPost*)contentPost showComments:(NSArray*)comments withEditMode:(BOOL)editOrNot andCommentIndexes:(NSDictionary*)indexDict{
    commentIndexDict = [NSMutableDictionary dictionaryWithDictionary:indexDict];
    [self contentPost:contentPost showComments:comments withEditMode:editOrNot];
}

- (void)commentController:(GSCommentViewController *)controller prepareForUpdateComment:(Comment *)oldComment atIndex:(NSInteger)index{
    [self dismissControllerModal];
    [self showCommentView:index withOldComment:oldComment];
}

- (void)commentController:(GSCommentViewController *)controller deleteComment:(Comment *)oldComment atIndex:(NSInteger)index dismiss:(BOOL)dismiss{
    if (dismiss) {
        [self dismissControllerModal];
    }
    [self contentPost:nil deleteComment:oldComment atIndex:index];
}

- (void)commentController:(GSCommentViewController *)controller openFashionistaWithName:(NSString *)userName{
    [self dismissControllerModal];
    [self openFashionistaWithUsername:userName];
}

#pragma mark - Keywords

// Initialize a specific Fetched Results Controller to fetch the local keywords in order to force user to select one
- (BOOL)initFetchedResultsControllerWithEntity:(NSString *)entityName andPredicate:(NSString *)predicate withString:(NSString *)stringForPredicate sortingWithKey:(NSString *)sortKey ascending:(BOOL)ascending
{
    BOOL bReturn = FALSE;
    
    if(_keywordsFetchedResultsController == nil)
    {
        NSManagedObjectContext *currentContext = [RKObjectManager sharedManager].managedObjectStore.mainQueueManagedObjectContext;
        
        if (_keywordssFetchRequest == nil)
        {
            if(!(stringForPredicate == nil))
            {
                if(!([stringForPredicate isEqualToString:@""]))
                {
                    _keywordssFetchRequest = [[NSFetchRequest alloc] init];
                    
                    // Entity to look for
                    
                    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:currentContext];
                    
                    [_keywordssFetchRequest setEntity:entity];
                    
                    // Filter results
                    
                    [_keywordssFetchRequest setPredicate:[NSPredicate predicateWithFormat:predicate, stringForPredicate]];
                    
                    // Sort results
                    
                    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortKey ascending:ascending];
                    
                    [_keywordssFetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
                    
                    [_keywordssFetchRequest setFetchBatchSize:20];
                }
            }
        }
        
        if(_keywordssFetchRequest)
        {
            // Initialize Fetched Results Controller
            
            //NSSortDescriptor *tmpSortDescriptor = (NSSortDescriptor *)[_wardrobesFetchRequest sortDescriptors].firstObject;
            
            NSFetchedResultsController *fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:_keywordssFetchRequest managedObjectContext:currentContext sectionNameKeyPath:nil cacheName:nil];
            
            _keywordsFetchedResultsController = fetchedResultsController;
            
            _keywordsFetchedResultsController.delegate = self;
        }
        
        if(_keywordsFetchedResultsController)
        {
            // Perform fetch
            
            NSError *error = nil;
            
            if (![_keywordsFetchedResultsController performFetch:&error])
            {
                // TODO: Update to handle the error appropriately. Now, we just assume that there were not results
                
                NSLog(@"Couldn't fetch wardrobes. Unresolved error: %@, %@", error, [error userInfo]);
                
                return FALSE;
            }
            
            bReturn = ([_keywordsFetchedResultsController fetchedObjects].count > 0);
        }
    }
    
    return bReturn;
}

#pragma mark - Statistics


-(void)uploadPostView
{
    // Check that the name is valid
    
    if (!(thePost.idFashionistaPost == nil))
    {
        if(!([thePost.idFashionistaPost isEqualToString:@""]))
        {
            // Post the ProductView object
            
            FashionistaPostView * newPostView = [[FashionistaPostView alloc] init];
            
            [newPostView setPostId:thePost.idFashionistaPost];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newPostView setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newPostView setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newPostView setFingerprint:appDelegate.finger.fingerprint];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostView, nil];
            
            [self performRestPost:ADD_POSTVIEW withParamaters:requestParameters];
        }
    }
}

-(void)uploadPostSharedIn:(NSString *) sSocialNetwork
{
    // Check that the name is valid
    
    if (!(thePost.idFashionistaPost == nil))
    {
        if(!([thePost.idFashionistaPost isEqualToString:@""]))
        {
            // Post the FashionistaPostShared object
            
            FashionistaPostShared * newPostShared = [[FashionistaPostShared alloc] init];
            
            newPostShared.socialNetwork = sSocialNetwork;
            
            [newPostShared setPostId:thePost.idFashionistaPost];
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            if (!(appDelegate.currentUser == nil))
            {
                if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
                {
                    [newPostShared setUserId:appDelegate.currentUser.idUser];
                }
            }
            
            if(!(_searchQuery == nil))
            {
                if(!(_searchQuery.idSearchQuery == nil))
                {
                    if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                    {
                        [newPostShared setStatProductQueryId:_searchQuery.idSearchQuery];
                    }
                }
            }
            
            [newPostShared setFingerprint:appDelegate.finger.fingerprint];
            
            NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostShared, nil];
            
            [self performRestPost:ADD_POSTSHARED withParamaters:requestParameters];
        }
    }
}

-(void) afterSharedIn:(NSString *) sSocialNetwork
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(!([appDelegate.currentUser.idUser isEqualToString:thePost.userId]))
    {
        [self uploadPostSharedIn:sSocialNetwork];
    }
}

-(void)uploadCommentView:(Comment *) comment
{
    // Check that the name is valid
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Post the ProductView object
    
    CommentView * newCommentView = [[CommentView alloc] init];
    [newCommentView setCommentId:comment.idComment];
    
    if (!(appDelegate.currentUser == nil))
    {
        if (!([appDelegate.currentUser.idUser isEqualToString:@""]))
        {
            [newCommentView setUserId:appDelegate.currentUser.idUser];
        }
    }
    
    [newCommentView setFingerprint:appDelegate.finger.fingerprint];
    
    if(!(newCommentView == nil))
    {
        NSArray * requestParameters = [[NSArray alloc] initWithObjects:newCommentView, nil];
        
        [self performRestPost:ADD_COMMENTVIEW withParamaters:requestParameters];
    }
}

-(void) postAnayliticsIntervalTimeBetween:(NSDate *) startTime and:(NSDate *) endTime
{
    if (!(thePost.idFashionistaPost == nil))
    {
        if(!([thePost.idFashionistaPost isEqualToString:@""]))
        {
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            
            //            if(!([appDelegate.currentUser.idUser isEqualToString:self.shownPost.userId]))
            if ([self.idUserViewing isEqualToString:thePost.userId] == NO)
            {
                // Post the ProductView object
                
                FashionistaPostViewTime * newPostViewTime = [[FashionistaPostViewTime alloc] init];
                
                [newPostViewTime setStartTime:startTime];
                
                [newPostViewTime setEndTime:endTime];
                
                [newPostViewTime setPostId:thePost.idFashionistaPost];
                
                
                if (!(self.idUserViewing == nil))
                {
                    if (!([self.idUserViewing isEqualToString:@""]))
                    {
                        [newPostViewTime setUserId:self.idUserViewing];
                    }
                }
                
                if(!(_searchQuery == nil))
                {
                    if(!(_searchQuery.idSearchQuery == nil))
                    {
                        if(!([_searchQuery.idSearchQuery isEqualToString:@""]))
                        {
                            [newPostViewTime setStatProductQueryId:_searchQuery.idSearchQuery];
                        }
                    }
                }
                
                [newPostViewTime setFingerprint:appDelegate.finger.fingerprint];
                
                NSArray * requestParameters = [[NSArray alloc] initWithObjects:newPostViewTime, nil];
                
                [self performRestPost:ADD_POSTVIEWTIME withParamaters:requestParameters];
            }
        }
    }
}

-(void)showFullVideo:(NSInteger)orientation {
    FullVideoViewController *fullVC = [self.storyboard instantiateViewControllerWithIdentifier:@"FullVideoViewController"];
    fullVC.modalPresentationStyle = UIModalPresentationPopover;
    fullVC.orientation = orientation;
    NSString* url = [self.contentView getVideoURL];
    if (url == nil || [url isEqualToString:@""]) {
        return;
    }
    fullVC.currentTime = [self.contentView getPlayer];
    fullVC.isSound = [self.contentView hasSoundNow];
    fullVC.videoURL = url;
    fullVC.delegate = self;
    [self presentViewController:fullVC animated:YES completion:nil];
}

@end
