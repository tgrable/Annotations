//
//  Model.m
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import "Model.h"

@implementation Model

- (id)init {
    
    self = [super init];
    if (self != nil){
        
    }
    
    return self;
}

#pragma mark -
#pragma mark - Core Data stack
- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.trekk.Annotations" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Annotations" withExtension:@"momd"];
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Annotations.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:coordinator];
    return managedObjectContext;
}


#pragma mark
#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContextLocal = self.managedObjectContext;
    if (managedObjectContextLocal != nil) {
        NSError *error = nil;
        if ([managedObjectContextLocal hasChanges] && ![managedObjectContextLocal save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            //ALog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)saveAnnotationWithTitle:(NSString *)title andBody:(NSString *)body andXPosition:(int)xpos andYPosition:(int)ypos complete:(void (^)(BOOL completionFlag, NSString * key))doneBlock {
    
    NSString *key = [[NSUUID UUID] UUIDString];
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *annotationInformantion = [NSEntityDescription insertNewObjectForEntityForName:@"Annotation" inManagedObjectContext:context];
    [annotationInformantion setValue:key forKey:@"objectKey"];
    [annotationInformantion setValue:title forKey:@"title"];
    [annotationInformantion setValue:body forKey:@"body"];
    [annotationInformantion setValue:[NSNumber numberWithInt:xpos] forKey:@"xposition"];
    [annotationInformantion setValue:[NSNumber numberWithInt:ypos] forKey:@"yposition"];
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        doneBlock(NO, @"");
    }
    else {
        NSLog(@"Data Saved");
        doneBlock(YES, key);
    }
}

- (void)deleteAnnotationWithKey:(NSString *)key completeBlock:(completeBlock)completeFlag {
    
    NSError *error = nil;
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Annotation" inManagedObjectContext:[self managedObjectContext]]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"objectKey==%@",key]];
    
    Annotation *annotation = [[[self managedObjectContext] executeFetchRequest:request error:&error] lastObject];
    NSLog(@"Title %@", annotation.title);
    NSLog(@"Body %@", annotation.body);
    NSLog(@"X Position %@", annotation.xposition);
    NSLog(@"Y Position %@", annotation.yposition);
    
    NSLog(@"Annotation object %@", annotation);
    
    if (annotation != nil && error == nil){
        
        [[self managedObjectContext] deleteObject:annotation];
        NSError *error = nil;
        if (![[self managedObjectContext] save:&error]) {
            //Handle any error with the saving of the context
            NSLog(@"ERROR REPORT 2 %@", error);
            completeFlag(NO);
        }else{
            completeFlag(YES);
        }
    } else {
        NSLog(@"ERROR REPORT ! %@", error);
        completeFlag(NO);
    }
    
}

- (NSArray *)getAllAnnotations {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Annotation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    
    return fetchedObjects;
}

- (void)displayAllObjectsIntheDatabase {
    NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Annotation" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *mod in fetchedObjects) {
        NSLog(@"title: %@", [mod valueForKey:@"title"]);
        NSLog(@"body: %@", [mod valueForKey:@"body"]);
        NSLog(@"xposition: %@", [mod valueForKey:@"xposition"]);
        NSLog(@"yposition: %@", [mod valueForKey:@"yposition"]);
    }
}

@end