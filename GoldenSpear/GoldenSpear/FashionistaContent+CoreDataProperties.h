//
//  FashionistaContent+CoreDataProperties.h
//  
//
//  Created by Adria Vernetta Rubio on 16/6/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FashionistaContent.h"

NS_ASSUME_NONNULL_BEGIN

@interface FashionistaContent (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *fashionistaPostId;
@property (nullable, nonatomic, retain) NSString *idFashionistaContent;
@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSNumber *image_height;
@property (nullable, nonatomic, retain) NSNumber *image_width;
@property (nullable, nonatomic, retain) NSString *imageText;
@property (nullable, nonatomic, retain) id keywordsId;
@property (nullable, nonatomic, retain) NSNumber *order;
@property (nullable, nonatomic, retain) NSString *text;
@property (nullable, nonatomic, retain) NSString *video;
@property (nullable, nonatomic, retain) NSString *wardrobeId;
@property (nullable, nonatomic, retain) NSSet<KeywordFashionistaContent *> *keywords;
@property (nullable, nonatomic, retain) FashionistaPost *postContainedAt;

@end

@interface FashionistaContent (CoreDataGeneratedAccessors)

- (void)addKeywordsObject:(KeywordFashionistaContent *)value;
- (void)removeKeywordsObject:(KeywordFashionistaContent *)value;
- (void)addKeywords:(NSSet<KeywordFashionistaContent *> *)values;
- (void)removeKeywords:(NSSet<KeywordFashionistaContent *> *)values;

@end

NS_ASSUME_NONNULL_END
