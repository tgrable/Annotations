//
//  AnnotateWebView.h
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "AnnotationView.h"

@protocol AnnotateWebViewDataSourse;
@protocol AnnotateWebViewDelegate;

@interface AnnotateWebView : UIWebView <UIGestureRecognizerDelegate, AnnotationViewWebViewDelegate> {
    NSArray *annotations;
    CGPoint offset;
    CGFloat scale;
    BOOL didLoadAnnotationData;
}

@property (weak, nonatomic) id <AnnotateWebViewDataSourse> dataSource;
@property (weak, nonatomic) id <AnnotateWebViewDelegate> delegate;

@property (strong, nonatomic, readonly, getter = webScrollView) UIScrollView *webScrollView;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) BOOL isEditable;

- (void)reloadAnnotationData;
- (void)didTapWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer;

@end

@protocol AnnotateWebViewDataSourse <NSObject>

- (NSUInteger)numberOfAnnotationsInWebView:(AnnotateWebView *)webView;
- (AnnotationView *)webView:(AnnotateWebView *)webView annotationForIndex:(NSUInteger)index;
- (void)annotationIsDeleting;
- (void)annotationDeletionResponse:(BOOL)flag withBody:(NSString *)body;
- (void)annotationIsSaving;
- (void)annotationSaveResponse:(BOOL)flag withBody:(NSString *)body;
- (void)detectIfTheKeyboardNeedsToBeMovedInViewController:(CGPoint)position;
- (void)closeKeyboardWhenCloseButtonHit;
@end

@protocol AnnotateWebViewDelegate <NSObject>

- (void)didReceiveTapAtAnnotationPosition:(CGPoint)position;

@end
