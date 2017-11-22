//
//  AnnotateWebView.m
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import "AnnotateWebView.h"

@implementation AnnotateWebView

@synthesize dataSource = _dataSource;
@synthesize webScrollView = _webScrollView;
@synthesize tapGestureRecognizer = _tapGestureRecognizer;
@synthesize isEditable = _isEditable;

- (UIScrollView *)webScrollView {
    if (_webScrollView != nil) {
        return _webScrollView;
    }
    
    for (id subview in self.subviews) {
        if ([[subview class] isSubclassOfClass:[UIScrollView class]]) {
            _webScrollView = subview;
            break;
        }
    }
    
    return _webScrollView;
}

- (void)reloadAnnotationData {
    NSUInteger count = (_dataSource != nil) ? [_dataSource numberOfAnnotationsInWebView:self] : 0;
    NSMutableArray *annotationList = [NSMutableArray arrayWithCapacity:count];
    
    for (AnnotationView *annotation in annotations) {
        [annotation removeFromSuperview];
    }

    
    for (NSUInteger index = 0; index < count; index++) {
        AnnotationView *annotationView = [_dataSource webView:self annotationForIndex:index];
        annotationView.delegate = self;
        [annotationList addObject:annotationView];
        
        // Add the annotation as a subview.
        [[self webScrollView] addSubview:annotationView];
    }
    
    annotations = [[NSArray alloc] initWithArray:annotationList];
    
    didLoadAnnotationData = YES;
    
    [self layoutSubviews];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!didLoadAnnotationData) {
        [self reloadAnnotationData];
    }
    
    UIScrollView *scrollView = [self scrollView];
    
    offset = scrollView.contentOffset;
    scale = scrollView.zoomScale / scrollView.minimumZoomScale;

    for (AnnotationView *annotation in annotations) {
        
        // Calculate the new frame for the annotation view based on the
        // annotation's position and the web view's offset and scale.
        CGFloat width = annotation.frame.size.width;
        CGFloat height = annotation.frame.size.height;

        CGFloat x = (annotation.position.x * scale) - (width / 2);
        CGFloat y = (annotation.position.y * scale) - (height / 2);

        annotation.frame = CGRectMake(x, y, width, height);
    }
}

- (void)didTapWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint position = [tapGestureRecognizer locationInView:self];

    position.x = (position.x + offset.x) / scale;

    if ([self.delegate respondsToSelector:@selector(didReceiveTapAtAnnotationPosition:)]) {
        [self.delegate didReceiveTapAtAnnotationPosition:position];
    }
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWithGestureRecognizer:)];
        _tapGestureRecognizer.delegate = self;
        
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        didLoadAnnotationData = NO;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if ((self = [super initWithCoder:decoder])) {
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapWithGestureRecognizer:)];
        _tapGestureRecognizer.delegate = self;
        
        [self addGestureRecognizer:_tapGestureRecognizer];
        
        didLoadAnnotationData = NO;
    }
    
    return self;
}

#pragma mark -
#pragma mark - Gesture recognizer delegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    BOOL doesIntersectAnnotation = NO;
    
    for (AnnotationView *annotation in annotations) {
        CGRect newRect = annotation.bounds;
        newRect.size.width = newRect.size.width + 125.0f;
        newRect.size.height = newRect.size.height + 62.5f;

        if (CGRectContainsPoint(newRect, [touch locationInView:annotation])) {
            doesIntersectAnnotation = YES;
            break;
        }
        else {
            doesIntersectAnnotation = NO;
        }
    }
    return !doesIntersectAnnotation;
}

#pragma mark -
#pragma mark - AnnotationViewWebViewDelegate

- (void)deletingNotificationSentToWebview {
    
    [_dataSource annotationIsDeleting];
}

- (void)deletingFinishedSentToWebView:(BOOL)flag withBody:(NSString *)body {
    
    [_dataSource annotationDeletionResponse:flag withBody:body];
}

- (void)saveNotificationSentToWebview {
    
    [_dataSource annotationIsSaving];
}

- (void)saveFinishedSentToWebView:(BOOL)flag withBody:(NSString *)body {
    
    [_dataSource annotationSaveResponse:flag withBody:body];
}

- (void)detectIfTheKeyboardNeedsToBeMoved:(CGPoint)position {
    
    //NSLog(@"detectIfTheKeyboardNeedsToBeMoved x %f, y %f", position.x, position.y);
    [_dataSource detectIfTheKeyboardNeedsToBeMovedInViewController:position];
}

- (void)closeKeyBoardNotification {
    
    [_dataSource closeKeyboardWhenCloseButtonHit];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end