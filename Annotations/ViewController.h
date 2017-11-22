//
//  ViewController.h
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AnnotateWebView.h"
#import "Annotation.h"

@interface ViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, AnnotateWebViewDataSourse, AnnotateWebViewDelegate> {
    Model *model;
    BOOL annotationFlag;
    
}

@property (nonatomic, strong) Model *model;
@property (strong, nonatomic) AnnotateWebView *webView;
@property (strong, nonatomic) NSMutableArray *annotations;
@property BOOL annotationFlag;

@end

