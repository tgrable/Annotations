//
//  Model.h
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Annotation.h"  

@interface Model : NSObject {
    //core data objects
    NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}
typedef void(^completeBlock)(BOOL);
typedef void(^completeBlockValue)(BOOL completionFlag, NSString * key);
//core data objects
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

// Core Data Function Prototypes
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

//Function Prototypes For Annotations
- (NSArray *)getAllAnnotations;
- (void)displayAllObjectsIntheDatabase;
- (void)saveAnnotationWithTitle:(NSString *)title
                        andBody:(NSString *)body
                   andXPosition:(int)xpos
                   andYPosition:(int)ypos
                       complete:(void (^)(BOOL completionFlag, NSString * key))doneBlock;
- (void)deleteAnnotationWithKey:(NSString *)key completeBlock:(completeBlock)completeFlag;
@end
