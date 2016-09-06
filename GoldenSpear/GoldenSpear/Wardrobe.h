//
//  Wardrobe.h
//  GoldenSpear
//
//  Created by Jose Antonio Sanchez Martinez on 27/07/15.
//  Copyright (c) 2015 GoldenSpear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Wardrobe : NSManagedObject

@property (nonatomic, retain) NSString * idWardrobe;
@property (nonatomic, retain) id itemsId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * preview_image;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * fashionistaContentId;
@property (nonatomic, retain) User *user;

@end
