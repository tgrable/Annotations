//
//  Annotation.h
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface Annotation : NSManagedObject

@property (nonatomic, retain) NSString *objectKey;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *body;
@property (nonatomic, retain) NSNumber *xposition;
@property (nonatomic, retain) NSNumber *yposition;

@end
