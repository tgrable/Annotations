//
//  AnnotationView.h
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "Model.h"

@protocol AnnotationViewWebViewDelegate;

@interface AnnotationView : UIView <UITextViewDelegate> {
    UIButton *button, *deleteButton;
    UIView *expandedView;
    UITextView *textView;
    NSString *documentTitle;
    NSString *objectKey;
    Model *model;
}

@property (weak, nonatomic) id <AnnotationViewWebViewDelegate> delegate;

@property (nonatomic, strong)Model *model;
@property (nonatomic) UIButton *button, *deleteButton;
@property (nonatomic) UIView *expandedView;
@property (nonatomic) CGPoint position;
@property (nonatomic) UITextView *textView;
@property (nonatomic) NSString *documentTitle, *objectKey;

- (void)updateDeleteButton;
- (id)initWithPosition:(CGPoint)position expandedView:(UIView *)exView andTitle:(NSString *)title andNote:(NSString *)note andKey:(NSString *)key;

@end

@protocol AnnotationViewWebViewDelegate <NSObject>

- (void)deletingNotificationSentToWebview;
- (void)deletingFinishedSentToWebView:(BOOL)flag withBody:(NSString *)body;
- (void)saveNotificationSentToWebview;
- (void)saveFinishedSentToWebView:(BOOL)flag withBody:(NSString *)body;
- (void)detectIfTheKeyboardNeedsToBeMoved:(CGPoint)position;
- (void)closeKeyBoardNotification;
@end
