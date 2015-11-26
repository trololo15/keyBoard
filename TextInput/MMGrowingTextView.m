//
//  MMGrowingTextView.m
//  SocketChat
//
//  Created by Manuel Menzella on 8/7/14.
//  Copyright (c) 2014 Manuel Menzella. All rights reserved.
//

#import "MMGrowingTextView.h"

@interface MMGrowingTextView ()

@end

@implementation MMGrowingTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInitializer];
    }
    return self;
}

- (void)commonInitializer
{
    self.minHeight = 40.0;
    self.maxHeight = 120.0f;
    self.animationDuration = 0.1f;
    self.animateHeightChange = YES;
    
    self.scrollEnabled = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.contentInset = UIEdgeInsetsZero;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidBeginEditing:) name:UITextViewTextDidBeginEditingNotification object:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidChange:) name:UITextViewTextDidChangeNotification object:self];
}

- (void)setMinHeight:(CGFloat)minHeight
{
    _minHeight = minHeight;
    if (self.text.length != 0) [self updateHeight];
}

- (void)setMaxHeight:(CGFloat)maxHeight
{
    _maxHeight = maxHeight;
    if (self.text.length != 0) [self updateHeight];
}

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateHeight];
}

- (void)setText:(NSString *)text
{
    [super setText:text];
    [self textViewDidChange:self];
}

- (void)updateHeight
{
    CGFloat newHeight = [self measureHeight];
    CGFloat newHeightC = newHeight;
    
    if (newHeight < self.minHeight) newHeightC = self.minHeight;
    if (newHeight > self.maxHeight) {
        newHeightC = self.maxHeight;
        if (!self.isScrollEnabled) {
            [self setScrollEnabled:YES];
        }
    } else {
        [self setScrollEnabled:NO];
    }
    
    if (newHeightC != self.frame.size.height) {
        if (self.animateHeightChange) {
            [UIView animateWithDuration:self.animationDuration delay:0 options:(UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState) animations:^{
                [self resizeTextView:newHeightC];
            }completion:nil];
        } else {
            [self resizeTextView:newHeightC];
        }
    }
    
    // Fix "last line" bug on iOS 7
    [self resetScrollPositionForIOS7];
    [self performSelector:@selector(resetScrollPositionForIOS7) withObject:nil afterDelay:0.1];
    
}

-(void)resizeTextView:(NSInteger)newHeight
{
    if ([self.growingDelegate respondsToSelector:@selector(growingTextView:willChangeHeight:)]) {
        [self.growingDelegate growingTextView:self willChangeHeight:newHeight];
    }
    
    CGRect frame = self.frame;
    frame.size.height = newHeight;
    self.frame = frame;
    
    [self reloadInputViews];
}

- (CGFloat)measureHeight
{
    return ceilf([self sizeThatFits:self.frame.size].height);
}

// Fix "last line" bug on iOS 7
- (void)resetScrollPositionForIOS7
{
    CGPoint contentOffset = [self correctedContentOffsetForIOS7:self.contentOffset];
    if (!CGPointEqualToPoint(contentOffset, CGPointZero)) self.contentOffset = contentOffset;
}

- (CGPoint)correctedContentOffsetForIOS7:(CGPoint)contentOffset
{
    CGPoint newContentOffset = CGPointZero;
    CGRect r = [self caretRectForPosition:self.selectedTextRange.end];
    CGFloat caretY =  MAX(r.origin.y - self.frame.size.height + r.size.height + 4, 0);
    if (contentOffset.y < caretY && r.origin.y != INFINITY) {
        newContentOffset = CGPointMake(0, caretY);
    }
    return newContentOffset;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self resetScrollPositionForIOS7];
}

// Fix "paste" bug on iOS 7
- (void)paste:(id)sender
{
    self.scrollEnabled = YES;
    [super paste:sender];
    [self updateHeight];
}

// Fix "overscrolling" bug when pasting long text on iOS 7
- (void)setContentOffset:(CGPoint)contentOffset
{
    // Do not apply fix when manually scrolling
    if (!self.decelerating && !self.tracking && !self.dragging && !CGPointEqualToPoint(self.contentOffset, CGPointZero) && self.selectedRange.length == 0) {
        if (contentOffset.y > self.contentSize.height - self.frame.size.height)
            contentOffset = CGPointMake(contentOffset.x, self.contentSize.height - self.frame.size.height);
        
        CGPoint newContentOffset = [self correctedContentOffsetForIOS7:contentOffset];
        if (!CGPointEqualToPoint(newContentOffset, CGPointZero)) contentOffset = newContentOffset;
    }
    
	[super setContentOffset:contentOffset];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
