//
//  MMGrowingTextView.h
//  SocketChat
//
//  Created by Manuel Menzella on 8/7/14.
//  Copyright (c) 2014 Manuel Menzella. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMGrowingTextViewDelegate;

@interface MMGrowingTextView : UITextView

@property (nonatomic) CGFloat minHeight;
@property (nonatomic) CGFloat maxHeight;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) BOOL animateHeightChange;

@property (nonatomic, assign) NSObject<MMGrowingTextViewDelegate> *growingDelegate;

@end

@protocol MMGrowingTextViewDelegate
@optional
- (void)growingTextView:(MMGrowingTextView *)growingTextView willChangeHeight:(float)height;
@end