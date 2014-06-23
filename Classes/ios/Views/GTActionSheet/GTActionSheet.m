//
//  GTActionSheet.m
//  GTFoundation
//
//  Created by Gianluca Tranchedone on 14/08/13.
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Gianluca Tranchedone
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "GTActionSheet.h"

#if TARGET_OS_IPHONE

@interface GTActionSheet () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) NSMutableArray *blocks;
@property (nonatomic, strong) NSMutableArray *buttons;
@property (nonatomic, strong) UIView *buttonsBackgroundView;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSUInteger cancelButtonIndex;
@property (nonatomic, assign) NSUInteger destructiveButtonIndex;

@end

@implementation GTActionSheet

#pragma mark - Superclass Methods Override -

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithTitle:nil cancelButtonTitle:@"Cancel"];
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:[UIScreen mainScreen].bounds];
}

#pragma mark - Public APIs -

- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle
{
	return [self initWithTitle:title cancelButtonTitle:cancelButtonTitle cancelBlock:nil];
}

- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle cancelBlock:(void (^)(void))cancelBlock
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        _font = [[UIFont preferredFontForTextStyle:UIFontTextStyleBody] fontWithSize:[UIFont buttonFontSize]];
        _otherButtonsTintColor = [UIApplication sharedApplication].delegate.window.tintColor;
        _buttonsBackgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.95];
        _separatorColor = [UIColor colorWithWhite:0.9 alpha:1];
        _destructiveButtonTintColor = [UIColor redColor];
        _cancelButtonTintColor = [UIColor grayColor];
        
        self.blocks = [NSMutableArray array];
        self.buttons = [NSMutableArray array];
        
        self.title = title;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        self.cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle selectionBlock:cancelBlock];
        
	    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
	                                                                                           action:@selector(didTapOutsideSheetBounds:)];
	    tapGestureRecognizer.delegate = self;
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)show
{
	[self showInView:[UIApplication sharedApplication].delegate.window];
}

- (void)showInView:(UIView *)view
{
	view.userInteractionEnabled = NO;
	self.userInteractionEnabled = NO;
    
	__weak GTActionSheet *weakSelf = self;
    
	[self setAlpha:0];
	[view addSubview:self];
	[self prepareForDisplay];
	[self.buttonsBackgroundView setFrame:CGRectOffset(self.buttonsBackgroundView.frame, 0, self.bounds.size.height)];
    
	[UIView animateWithDuration:0.1 animations:^{
		weakSelf.alpha = 1;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			weakSelf.buttonsBackgroundView.frame = CGRectOffset(self.buttonsBackgroundView.frame, 0, -self.bounds.size.height);
		} completion:^(BOOL didFinish) {
			weakSelf.userInteractionEnabled = YES;
			view.userInteractionEnabled = YES;
		}];
	}];
}

- (void)dismiss
{
    [self setUserInteractionEnabled:NO];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.buttonsBackgroundView setFrame:CGRectOffset(self.buttonsBackgroundView.frame, 0, self.bounds.size.height)];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.alpha = 0;
        } completion:^(BOOL didFinish) {
            [self removeFromSuperview];
        }];
    }];
}

- (void)dismissWithSelectedButtonIndex:(NSUInteger)index
{
    if ((NSInteger)index < 0 || index > self.buttons.count || index == NSNotFound) {
        return;
    }
    else {
        if (index < self.blocks.count) {
            void (^selectionBlock)(void) = [self.blocks objectAtIndex:index];
            selectionBlock();
        }
        
        [self dismiss];
    }
}

- (NSUInteger)addButtonWithTitle:(NSString *)title
{
    return [self addButtonWithTitle:title selectionBlock:nil];
}

- (NSUInteger)addButtonWithTitle:(NSString *)title selectionBlock:(void (^)(void))selectionBlock
{
	NSUInteger newButtonIndex = self.buttons.count;
    
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
	button.titleLabel.numberOfLines = 0;
    
	[button setTitle:title forState:UIControlStateNormal];
	[button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    
	[self.buttons addObject:button];
	[self.blocks addObject:[(selectionBlock ?: ^{}) copy]];
    
	return newButtonIndex;
}

- (void)setDestructiveButtonIndex:(NSUInteger)destructiveButtonIndex
{
    if (destructiveButtonIndex < self.buttons.count) {
        _destructiveButtonIndex = destructiveButtonIndex;
    }
}

- (NSUInteger)addDestructiveButtonWithTitle:(NSString *)title selectionBlock:(void (^)(void))selectionBlock
{
    NSUInteger index = [self addButtonWithTitle:title selectionBlock:selectionBlock];
    [self setDestructiveButtonIndex:index];
    
    return index;
}

#pragma mark - Private APIs -

- (void)prepareForDisplay
{
    UIView *buttonsBackgroundView = [[UIView alloc] init];
    buttonsBackgroundView.backgroundColor = self.buttonsBackgroundColor;
    
    CGSize buttonsSize = CGSizeMake(CGRectGetWidth(self.bounds), 44.0f);
    CGRect nextButtonFrame = CGRectMake(0, 0, buttonsSize.width, buttonsSize.height);
    
    CGFloat buttonsBackgroundHeight = (buttonsSize.height * self.buttons.count) + (self.buttons.count - 1); // + for line separators
	if (self.title) buttonsBackgroundHeight += 41.0f;
    CGFloat maxButtonOriginY = buttonsBackgroundHeight;
    
    NSMutableArray *sortedButtons = [self.buttons mutableCopy];
    UIButton *cancelButton = [self.buttons objectAtIndex:self.cancelButtonIndex];
    [sortedButtons removeObject:cancelButton];
    [sortedButtons insertObject:cancelButton atIndex:0];
    
    if (self.destructiveButtonIndex) {
        UIButton *destructionButton = [self.buttons objectAtIndex:self.destructiveButtonIndex];
        [sortedButtons removeObject:destructionButton];
        [sortedButtons addObject:destructionButton];
    }
    
    for (int i = 0; i < sortedButtons.count; i++) {
        UIButton *button = [sortedButtons objectAtIndex:i];
        
        if (i == 0) {
            nextButtonFrame.origin.y = maxButtonOriginY - CGRectGetHeight(nextButtonFrame);
            button.tintColor = self.cancelButtonTintColor;
        }
        else {
            CGFloat separatorOriginY = maxButtonOriginY - 1;
            nextButtonFrame.origin.y = separatorOriginY - CGRectGetHeight(nextButtonFrame);
            
            if (i == self.destructiveButtonIndex) {
                button.tintColor = self.destructiveButtonTintColor;
            }
            
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(10.0f, separatorOriginY, CGRectGetWidth(self.bounds) - 20.0f, 1)];
            separator.backgroundColor = self.separatorColor;
            
            [buttonsBackgroundView addSubview:separator];
        }
        
	    maxButtonOriginY = CGRectGetMinY(nextButtonFrame);
        
	    button.tintColor = self.otherButtonsTintColor;
	    button.titleLabel.font = self.font;
        
        [button setFrame:nextButtonFrame];
        [buttonsBackgroundView addSubview:button];
	    [button setTitleColor:button.tintColor forState:UIControlStateNormal];
    }
    
    [buttonsBackgroundView setFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - buttonsBackgroundHeight, CGRectGetWidth(self.bounds), buttonsBackgroundHeight)];
    [self setButtonsBackgroundView:buttonsBackgroundView];
    
	if (self.title) {
		CGRect titleLabelFrame = CGRectInset(buttonsBackgroundView.bounds, 10.0f, 10.0f);
		titleLabelFrame.size.height = 20.0f;
        
		UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleLabelFrame];
		titleLabel.backgroundColor = self.buttonsBackgroundColor;
		titleLabel.textColor = self.otherButtonsTintColor;
		titleLabel.textAlignment = NSTextAlignmentCenter;
		titleLabel.text = self.title;
		titleLabel.font = self.font;
        
		CGRect separatorFrame = CGRectMake(10.0f, CGRectGetMaxY(titleLabel.frame) + 10.0f, CGRectGetWidth(self.bounds) - 20.0f, 1);
		UIView *separator = [[UIView alloc] initWithFrame:separatorFrame];
		separator.backgroundColor = self.separatorColor;
        
		[buttonsBackgroundView addSubview:separator];
		[buttonsBackgroundView addSubview:titleLabel];
	}
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:buttonsBackgroundView];
}

- (void)didSelectButton:(UIButton *)sender
{
    [self dismissWithSelectedButtonIndex:[self.buttons indexOfObject:sender]];
}

- (void)didTapOutsideSheetBounds:(UITapGestureRecognizer *)gestureRecognizer
{
	[self dismissWithSelectedButtonIndex:self.cancelButtonIndex];
}

#pragma mark - UIGestureRecognizerDelegate -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
	CGPoint location = [touch locationInView:gestureRecognizer.view];
	return !CGRectContainsPoint(self.buttonsBackgroundView.frame, location);
}

@end

#endif
