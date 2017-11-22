//
//  AnnotationView.m
//  Annotations
//
//  Created by Timothy C Grable on 2/3/16.
//  Copyright © 2016 Trekk Design. All rights reserved.
//

#import "AnnotationView.h"

@implementation AnnotationView

@synthesize model;
@synthesize button, deleteButton;
@synthesize expandedView;
@synthesize textView;
@synthesize documentTitle;
@synthesize objectKey;

- (id)initWithPosition:(CGPoint)position expandedView:(UIView *)exView andTitle:(NSString *)title andNote:(NSString *)note andKey:(NSString *)key {
    if ((self = [super initWithFrame:CGRectMake(0, 0, 250, 125)])) {
        
        NSLog(@"Position x %f y %f",position.x, position.y);
        _position = position;
        
        model = [[Model alloc] init];

        documentTitle = title;
        objectKey = key;

        button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(105, 30, 40, 40);
        button.backgroundColor = [UIColor yellowColor];
        button.layer.cornerRadius = 20.0;
        button.alpha = 0.6;
        [button addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        expandedView = exView;
        expandedView.frame = CGRectMake(0, 0, expandedView.frame.size.width, expandedView.frame.size.height);
        expandedView.hidden = YES;
        [expandedView.layer setCornerRadius:12.0];
        [expandedView.layer setMasksToBounds:YES];
        [self addSubview:expandedView];
        
        UIButton *close = [[UIButton alloc] initWithFrame:CGRectMake(10, 6, 50, 20)];
        [close setTitle:@"Close" forState:UIControlStateNormal];
        close.backgroundColor = [UIColor clearColor];
        [close addTarget:self action:@selector(didTapButton:) forControlEvents:UIControlEventTouchUpInside];
        [expandedView addSubview:close];
        
        deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(95, 6, 60, 20)];
        [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        deleteButton.backgroundColor = [UIColor clearColor];
        [deleteButton addTarget:self action:@selector(didTapDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        [expandedView addSubview:deleteButton];
        
        UIButton *save = [[UIButton alloc] initWithFrame:CGRectMake(190, 6, 50, 20)];
        [save setTitle:@"Save" forState:UIControlStateNormal];
        save.backgroundColor = [UIColor clearColor];
        [save addTarget:self action:@selector(saveButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [expandedView addSubview:save];
        
        textView = [[UITextView alloc] initWithFrame:CGRectMake(10, 30, 230, 85)];
        textView.text = note;
        textView.delegate = self;
        [textView.layer setCornerRadius:12.0];
        [textView.layer setMasksToBounds:YES];
        [expandedView addSubview:textView];
        
        // Make sure delete button is hidden for new annotations
        [self updateDeleteButton];
    }
    
    return self;
}

#pragma mark -
#pragma mark - UITextView Delegate
- (void)textViewDidChange:(UITextView *)textViewObject {
    
    NSLog(@"Text is changing %@", textViewObject.text);
    if ([textViewObject.text length] > 0) {
        [self updateDeleteButton];
    }
    
}

- (void)didTapButton:(id)sender {
    
    if (expandedView.hidden) {
        expandedView.hidden = NO;
        expandedView.userInteractionEnabled = YES;
        [_delegate detectIfTheKeyboardNeedsToBeMoved:_position];
    }
    else {
        expandedView.hidden = YES;
        expandedView.userInteractionEnabled = NO;
        [_delegate closeKeyBoardNotification];
    }
    
}

-(void)updateDeleteButton {
    
    NSLog(@"object key lenth %d", [objectKey length]);
    
    if ([objectKey length] > 0 && [textView.text length] > 0) {
        deleteButton.enabled = YES;
        deleteButton.alpha = 1.0;
    } else {
        deleteButton.enabled = NO;
        deleteButton.alpha = 0.0;
    }
}

- (void)didTapDeleteButton:(id)sender {
    
    if ([objectKey length] > 0) {
        [_delegate deletingNotificationSentToWebview];
        
        [model deleteAnnotationWithKey:objectKey completeBlock:^(BOOL completeFlag) {
            if (completeFlag) {
                expandedView.hidden = YES;
                expandedView.userInteractionEnabled = NO;
                button.hidden = YES;
                button.enabled = NO;
                [_delegate deletingFinishedSentToWebView:YES withBody:textView.text];
                NSLog(@"Delete Was A Success");
            } else {
                expandedView.hidden = NO;
                expandedView.userInteractionEnabled = YES;
                button.hidden = NO;
                button.enabled = YES;
                [_delegate deletingFinishedSentToWebView:YES withBody:textView.text];
                NSLog(@"Delete Failed");
            }
        }];
    }
}

- (void)saveButtonPressed:(id)sender {
    
    if ([textView.text length] > 0) {
        
        [model saveAnnotationWithTitle:documentTitle andBody:textView.text andXPosition:_position.x andYPosition:_position.y complete:^(BOOL completeFlag, NSString *key){
            if (completeFlag) {
                expandedView.hidden = YES;
                objectKey = key;
                NSLog(@"Save Was A Success");
                [self updateDeleteButton];
                [_delegate saveFinishedSentToWebView:YES withBody:textView.text];
            } else {
                expandedView.hidden = NO;
                expandedView.userInteractionEnabled = YES;
                objectKey = key;
                NSLog(@"Save Failed");
                [self updateDeleteButton];
                [_delegate saveFinishedSentToWebView:NO withBody:textView.text];
            }

        }];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end