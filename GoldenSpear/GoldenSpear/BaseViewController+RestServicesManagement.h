//
//  BaseViewController+RestServicesManagement.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 13/04/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import "BaseViewController.h"
#import "NSString+URLEncoding.h"

typedef enum connectionType
{
    PERFORM_SEARCH_WITHIN_PRODUCTS,
    PERFORM_SEARCH_WITHIN_PRODUCTS_NUMS,
    GET_SEARCH_GROUPS_WITHIN_PRODUCTS,
    GET_SEARCH_RESULTS_WITHIN_PRODUCTS,
    
    CHECK_SEARCH_STRING,
    CHECK_SEARCH_STRING_SUGGESTIONS,
    CHECK_SEARCH_STRING_AFTER_SEARCH,
    CHECK_SEARCH_STRING_SUGGESTIONS_AFTER_SEARCH,

    PERFORM_VISUAL_SEARCH,
    GET_DETECTION_STATUS,
    GET_SEARCH_QUERY,
    FINISHED_SEARCH_WITHOUT_RESULTS,
    FINISHED_SEARCH_WITHOUT_RESULTS_ONLY_BRAND,
//    GET_SEARCH_GROUP_KEYWORDS,
    GET_ALL_KEYWORDS,
    GET_KEYWORDS_FROM_STRING,
    GET_SEARCH_KEYWORDS,
    FINISHED_SEARCH_WITH_RESULTS,
    GET_SEARCHPRODUCTS_BRAND,
    GET_PRODUCT_BRAND,
    GET_SEARCH_SUGGESTEDFILTERKEYWORDS,

    GET_SEARCH_GROUPS_WITHIN_NEWSFEED,
    GET_SEARCH_RESULTS_WITHIN_NEWSFEED,
    
    GET_SEARCH_RESULTS_WITHIN_LIKES,
    
    GET_SEARCH_GROUPS_WITHIN_DISCOVER,
    GET_SEARCH_RESULTS_WITHIN_DISCOVER,
    
    PERFORM_SEARCH_WITHIN_TRENDING,
    GET_SEARCH_GROUPS_WITHIN_TRENDING,
    GET_SEARCH_RESULTS_WITHIN_TRENDING,
    
    PERFORM_SEARCH_WITHIN_HISTORY,
    GET_SEARCH_GROUPS_WITHIN_HISTORY,
    GET_SEARCH_RESULTS_WITHIN_HISTORY,
    
    PERFORM_SEARCH_WITHIN_FASHIONISTAPOSTS,
    GET_SEARCH_GROUPS_WITHIN_FASHIONISTAPOSTS,
    GET_SEARCH_RESULTS_WITHIN_FASHIONISTAPOSTS,
    
    PERFORM_SEARCH_WITHIN_FASHIONISTAS,
    PERFORM_SEARCH_WITHIN_FASHIONISTAS_LIKE_POST,
    GET_SEARCH_GROUPS_WITHIN_FASHIONISTAS,
    GET_SEARCH_RESULTS_WITHIN_FASHIONISTAS,
    
    PERFORM_SEARCH_USER_LIKE_POST,
    
    PERFORM_SEARCH_WITHIN_STYLES,
    GET_SEARCH_GROUPS_WITHIN_STYLES,
    GET_SEARCH_RESULTS_WITHIN_STYLES,
    GET_STYLESSEARCH_KEYWORDS,
    FINISHED_STYLESSEARCH_WITHOUT_RESULTS,
    FINISHED_STYLESSEARCH_WITH_RESULTS,
    
    PERFORM_SEARCH_WITHIN_BRANDS,
    PERFORM_SEARCHINITIAL_WITHIN_BRANDS,
    GET_SEARCH_GROUPS_WITHIN_BRANDS,
    GET_SEARCH_RESULTS_WITHIN_BRANDS,
    
    GET_PRODUCT,
    GET_PRODUCT_CONTENT,
    GET_PRODUCT_REVIEWS,
    GET_USER,
    GET_PRODUCT_FEATURES,
    GET_SIMILAR_PRODUCTS,
    GET_SIMILARPRODUCTS_GROUP,
    GET_SIMILARPRODUCTS_BRAND,
    GET_PRODUCT_GROUP,
    GET_PRODUCTGROUP_FEATURES,
    GET_PRODUCTGROUP_FEATURES_FOR_ADVANCED_SEARCH,
    GET_THE_LOOK,
    FINISHED_GETTHELOOK_WITHOUT_RESULTS,
    
    GET_USERS_FOR_AUTOFILL,
    
    GET_BRAND_PRODUCTS,
    GET_SEARCH_GROUPS_WITHIN_BRAND_PRODUCTS,
    GET_SEARCH_RESULTS_WITHIN_BRAND_PRODUCTS,
    GET_BRANDPRODUCTSSEARCH_KEYWORDS,
    FINISHED_BRANDPRODUCTSSEARCH_WITHOUT_RESULTS,
    FINISHED_BRANDPRODUCTSSEARCH_WITH_RESULTS,

    GET_POST,
    GET_FULL_POST,
    GET_POST_FOR_SHARE,
    GET_POST_CONTENT,
    GET_POST_CONTENT_KEYWORDS,
    ADD_WARDROBE_TO_CONTENT,
    GET_POST_CONTENT_WARDROBE,
    GET_POST_CONTENT_WARDROBE_CONTENT,
    GET_POST_AUTHOR,
    
    GET_ALLPRODUCTCATEGORIES,
    GET_ALLFEATURES,
    GET_ALLFEATUREGROUPS,
    GET_PRODUCTCATEGORIES,
    GET_SUBPRODUCTSCATEGORIES,
    GET_FEATUREGROUP_FEATURES,
    GET_PRIORITYBRANDS,
    GET_ALLBRANDS,

    GET_USER_WARDROBES,
    GET_USER_WARDROBES_CONTENT,
    GET_WARDROBE,
    GET_WARDROBE_CONTENT,
    
    GET_USER_NOTIFICATIONS,

    GET_USER_FOLLOWS,
    FOLLOW_USER,
    UNFOLLOW_USER,
    VERIFY_FOLLOWER,
    
    GET_PAGE,
    GET_USER_DISCOVER,
    GET_USER_NEWSFEED,
    GET_USER_HISTORY,
    GET_USER_LIKES,
    GET_FASHIONISTAWITHNAME,
    GET_FASHIONISTAWITHMAIL,
    GET_FASHIONISTA,
    GET_FASHIONISTAPAGES,
    GET_FASHIONISTAPOSTS,
    GET_FASHIONISTAPAGESFORSHARE,
    GET_FASHIONISTAPAGE_AUTHOR,
    GET_FASHIONISTAPAGE_POSTS,
    GET_FOLLOWERS_FOLLOWINGS_COUNT,
    UPLOAD_FASHIONISTAPAGE,
    UPLOAD_FASHIONISTAPAGE_IMAGE,
    DELETE_FASHIONISTA_PAGE,
    DELETE_POST,
    UPLOAD_FASHIONISTAPOST,
    UPLOAD_FASHIONISTAPOST_FORSHARE,
    UPLOAD_FASHIONISTAPOST_PREVIEWIMAGE,
    UPLOAD_FASHIONISTACONTENT,
    UPLOAD_FASHIONISTACONTENT_IMAGE,
    UPLOAD_FASHIONISTACONTENT_VIDEO,
    UPLOAD_REVIEW_VIDEO,
    DELETE_POST_CONTENT,
    ADD_KEYWORD_TO_CONTENT,
    REMOVE_KEYWORD_FROM_CONTENT,
    GET_POST_COMMENTS,
    UPLOAD_COMMENT_VIDEO,
    ADD_COMMENT_TO_POST, 
    GET_USER_LIKES_POST,
    GET_POST_LIKES_NUMBER,
    GET_ONLYPOST_LIKES_NUMBER,
    GET_POST_LIKES,
    LIKE_POST,
    UNLIKE_POST,
    DELETE_COMMENT,
    UPDATE_COMMENT,
    POST_FOLLOW,
    POST_UNFOLLOW,
    POST_YES_NOTICES,
    POST_NO_NOTICES,
    USER_IGNORE_NOTICES,
    USER_ACCEPT_NOTICES,
    
    GET_FULLSCREENBACKGROUNDAD,
    GET_POSTADAPTEDBACKGROUNDAD,
    GET_SEARCHADAPTEDBACKGROUNDAD,

    GET_SHARE,
    UPLOAD_SHARE,
    
    ADD_USERREPORT,
    ADD_POSTCONTENTREPORT,
    ADD_POSTCOMMENTREPORT,
    ADD_PRODUCTREPORT,
    ADD_PRODUCTVIEW,
    ADD_PRODUCTSHARED,
    ADD_PRODUCTPURCHASE,
    ADD_POSTVIEW,
    ADD_POSTVIEWTIME,
    ADD_POSTSHARED,
    ADD_FASHIONISTAVIEW,
    ADD_FASHIONISTAVIEWTIME,
    ADD_WARDROBEVIEW,
    ADD_COMMENTVIEW,
    ADD_REVIEWPRODUCTVIEW,
    ADD_WARDROBE,
    ADD_ITEM_TO_WARDROBE,
    ADD_POST_TO_WARDROBE,
    UPDATE_WARDROBE_NAME,
    REMOVE_ITEM_FROM_WARDROBE,
    DELETE_WARDROBE,
    
    ADD_REVIEW_TO_PRODUCT,
    
    GET_ALLCOUNTRIES,
    GET_STATESOFCOUNTRY,
    GET_CITIESOFSTATE,
    
    POST_FOLLOW_SOCIALNETWORK_USERS,
    
    GET_PRODUCT_AVAILABILITY,
    
    GET_NEAREST_POI
    
}
connectionType;

@interface BaseViewController (RestServicesManagement)

@property NSMutableArray * searchResults;

// Rest services management
- (NSString *)composeStringhWithTermsOfArray:(NSArray *)termsArray encoding:(BOOL)bEncoding;
- (NSString *)composeCommaSeparatedStringWithTermsOfArray:(NSArray *)termsArray encoding:(BOOL)bEncoding;

- (void) performRestGet:(connectionType)connection withParamaters:(NSArray *)parameters;
- (void) performRestPost:(connectionType)connection withParamaters:(NSArray *)parameters;
- (void) performRestPost:(connectionType)connection withParamaters:(NSArray *)parameters retrying:(BOOL) bRetrying;
- (void) performRestDelete:(connectionType)connection withParamaters:(NSArray *)parameters;
- (void)processAnswerToRestConnection:(connectionType) connection WithResult:(NSArray *) mappingResult lookingForClasses:(NSArray *) dataClasses andIfErrorMessage:(NSArray*)errorMessage;
- (void)getContentsForElement:(GSBaseElement *)element;
- (void) actionAfterSuccessfulAnswerToRestConnection:(connectionType)connection WithResult:(NSArray *) mappingResult;
- (void) processRestConnection:(connectionType) connection WithErrorMessage:(NSArray*)errorMessage forOperation:(RKObjectRequestOperation *)operation;
- (NSString *)getPatternForConnectionType:(connectionType)connection intendedForStringFormat:(BOOL)bForStringFormat;

@end
