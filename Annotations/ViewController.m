//
//  ViewController.m
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    NSString *documentTitle;
    UIButton *showHideAnnotations;
    UILabel *loadingLabel;
    UIView *loadingView;
}

@end

@implementation ViewController

@synthesize webView = _webView;
@synthesize annotations = _annotations;
@synthesize model;
@synthesize annotationFlag;

#pragma mark -
#pragma mark - View Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"Test" ofType:@"pdf"];
    documentTitle = @"Test";
    annotationFlag = NO;
    
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    UIView *banner = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
    banner.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:banner];
    
    showHideAnnotations = [[UIButton alloc] initWithFrame:CGRectMake(1024 - 250, 25, 200, 45)];
    [showHideAnnotations setTitle:@"Use Annotations" forState:UIControlStateNormal];
    [showHideAnnotations addTarget:self action:@selector(showOrHideAllAnnotationsButtonPress:) forControlEvents:UIControlEventTouchUpInside];
    [banner addSubview:showHideAnnotations];
    
    _webView = [[AnnotateWebView alloc] initWithFrame:CGRectMake(0, 70, self.view.bounds.size.width, self.view.bounds.size.height - 70)];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.scalesPageToFit = YES;
    _webView.delegate = self;
    _webView.scrollView.delegate = self;
    _webView.dataSource = self;
    [_webView loadRequest:request];
    _webView.userInteractionEnabled = YES;
    [self.view addSubview:_webView];
    
    loadingView = [[UIView alloc] initWithFrame:CGRectMake(342, 294, 340, 180)];
    loadingView.alpha = 0.0;
    loadingView.layer.cornerRadius = 5;
    loadingView.layer.masksToBounds = YES;
    loadingView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:loadingView];
    
    loadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 48)];
    loadingLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];
    loadingLabel.textColor = [UIColor whiteColor];
    loadingLabel.alpha = 0.7;
    loadingLabel.numberOfLines = 2.0;
    loadingLabel.textAlignment = NSTextAlignmentCenter;
    loadingLabel.text = @"";
    [loadingView addSubview:loadingLabel];
    
    UIActivityIndicatorView *activityIndicator = [UIActivityIndicatorView.alloc initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.frame = CGRectMake(153.0, 100.0, 35.0, 35.0);
    [activityIndicator setColor:[UIColor whiteColor]];
    [loadingView addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    model = [[Model alloc] init];
    
    _annotations = [NSMutableArray arrayWithArray:[self getAllAnnotations]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    for (UIView *v in [_webView.scrollView subviews]) {
        if ([v isKindOfClass:[AnnotationView class]]) {
            AnnotationView *av = (AnnotationView *)v;
            av.button.hidden = YES;
            av.button.enabled = NO;
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark - UIWebViewDelegate
- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {

}


#pragma mark -
#pragma mark - AnnotateWebViewDataSource
- (NSUInteger)numberOfAnnotationsInWebView:(AnnotateWebView *)webView {
    return [_annotations count];
}

- (AnnotationView *)webView:(AnnotateWebView *)webView annotationForIndex:(NSUInteger)index {
    return [_annotations objectAtIndex:index];
}

- (void)annotationIsDeleting {
    
    NSLog(@"annotationIsDeleting");
    loadingLabel.text = @"Deleting Annotation";
    loadingView.alpha = 0.8;
}

- (void)annotationDeletionResponse:(BOOL)flag withBody:(NSString *)body {
    
    loadingView.alpha = 0.0;
    // Failed to delete an annotation
    if (!flag) {
        NSLog(@"annotationDeletionResponse with no flag");
        [self displayMessage:@"There was an error deleting your annotation. If it keeps occurring please contact support."];
    } else {
        NSLog(@"Annotation has been deleted successfully");
        // Remove from local data
        int i = 0;
        for (AnnotationView *a in _annotations) {
            NSLog(@"Annotation object %@", a);
            if ([a.textView.text isEqualToString:body]) {
                // Break because data cannot be removed during enumeration
                break;
            }
            i++;
        }
        // Remove annotation
        [_annotations removeObjectAtIndex:i];
        NSLog(@"Annotations View Count %d", [_annotations count]);
        
        // Reload annotations
        [_webView reloadAnnotationData];
    }
}

- (void)annotationIsSaving {
    
    NSLog(@"annotationIsSaving");
    loadingLabel.text = @"Saving Annotation";
    loadingView.alpha = 0.8;
}

- (void)annotationSaveResponse:(BOOL)flag withBody:(NSString *)body {
    
    loadingView.alpha = 0.0;
    // Failed to delete an annotation
    if (!flag) {
        NSLog(@"annotationDeletionResponse with no flag");
        [self displayMessage:@"There was an error saving your annotation. If it keeps occurring please contact support."];
    } else {
        NSLog(@"Annotation has been saved successfully");
        // Reload annotations
        [_webView reloadAnnotationData];
        [self.view endEditing:YES];
    }
}

- (void)detectIfTheKeyboardNeedsToBeMovedInViewController:(CGPoint)position {
    
    //NSLog(@"detectIfTheKeyboardNeedsToBeMovedInViewController x %f, y %f", position.x, position.y);
    float relativeWebviewPosition = (position.y - _webView.scrollView.contentOffset.y);
    if (relativeWebviewPosition > 300) {
        float animateOffset = (position.y - 200);
        if (position.y > 708) {
          animateOffset = (position.y - (200 + _webView.scrollView.contentOffset.y));
        }
        CGPoint offset = CGPointMake(_webView.scrollView.contentOffset.x, (_webView.scrollView.contentOffset.y + animateOffset));
        [_webView.scrollView setContentOffset:offset animated:YES];
    }
}

- (void)closeKeyboardWhenCloseButtonHit{
    
    [self.view endEditing:YES];
}

#pragma mark -
#pragma mark - AnnotateWebViewDelegate
- (void)didReceiveTapAtAnnotationPosition:(CGPoint)position {
    
    // Make sure that annotations are on to perform this functionality
    if (annotationFlag) {
        
        position.y = (position.y + _webView.scrollView.contentOffset.y);
        
        UIView *expandedView = [[UIView alloc] initWithFrame:CGRectMake(position.x, (position.y + _webView.scrollView.contentOffset.y), 250, 125)];
        expandedView.backgroundColor = [UIColor lightGrayColor];
        
        AnnotationView *annotation = [[AnnotationView alloc] initWithPosition:position expandedView:expandedView andTitle:documentTitle andNote:@"" andKey:@""];
        [_annotations addObject:annotation];
        
        [_webView reloadAnnotationData];
    }
}

#pragma mark -
#pragma mark - ViewController Utility Functions For Annotations

- (NSArray *)getAllAnnotations {
    NSMutableArray *cdAnnotations = [NSMutableArray arrayWithArray:[model getAllAnnotations]];
    
    NSPredicate *annotationsPredicate = [NSPredicate predicateWithFormat:@"title == %@", documentTitle];
    NSArray *annotationsWithTitle = [cdAnnotations filteredArrayUsingPredicate:annotationsPredicate];
    
    NSMutableArray *annArray = [NSMutableArray array];
    
    for (Annotation *ann in annotationsWithTitle) {
        CGPoint point = CGPointMake([ann.xposition floatValue], [ann.yposition floatValue]);
        
        UIView *expandedView = [[UIView alloc] initWithFrame:CGRectMake([ann.xposition floatValue], [ann.yposition floatValue], 250, 125)];
        expandedView.backgroundColor = [UIColor lightGrayColor];
        
        AnnotationView *annotation = [[AnnotationView alloc] initWithPosition:point expandedView:expandedView andTitle:documentTitle andNote:ann.body andKey:ann.objectKey];
        [annArray addObject:annotation];
    }
    return annArray;
}

- (void)showOrHideAllAnnotationsButtonPress:(UIButton *)sender {
    
    NSMutableArray *annotationData = [NSMutableArray array];
    
    for (UIView *v in [_webView.scrollView subviews]) {
        if ([v isKindOfClass:[AnnotationView class]]) {
            [annotationData addObject:v];
        }
    }
    
    NSLog(@"Annotations Data Count %d", [annotationData count]);
    
    // Make sure there is annotation data before it is iterated over
    if ([annotationData count] > 0) {
        
        for (UIView *v in annotationData) {
            AnnotationView *av = (AnnotationView *)v;
            if (!annotationFlag) {
                av.button.hidden = NO;
                av.button.enabled = YES;
                av.expandedView.hidden = YES;
                [_webView layoutSubviews];
                //NSLog(@"Hide Annotations");
            }
            else {
                av.button.hidden = YES;
                av.button.enabled = NO;
                av.expandedView.hidden = YES;
                [_webView layoutSubviews];
                [self.view endEditing:YES];
                //NSLog(@"Use Annotations");
            }
        }
    }
    if (!annotationFlag) {
        annotationFlag = YES;
        [showHideAnnotations setTitle:@"Close Annotations" forState:UIControlStateNormal];
        //NSLog(@"Hide Annotations");
    } else {
        annotationFlag = NO;
        [showHideAnnotations setTitle:@"Use Annotations" forState:UIControlStateNormal];
        [self.view endEditing:YES];
        //NSLog(@"Use Annotations");
    }
}

#pragma mark -
#pragma mark - Universal Message Function
//universal view function to display dynamic alerts
-(void)displayMessage:(NSString *)message {
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"ALERT"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end