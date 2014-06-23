//
//  GTActionSheet.h
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

#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE

#import <UIKit/UIKit.h>

/**
 @abstract GTActionSheet is a subclass of UIActionSheet that takes advantage of blocks to add to its superclass block-based and utility APIs.
 */
@interface GTActionSheet : UIView

@property (nonatomic, strong) UIFont *font UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *separatorColor UI_APPEARANCE_SELECTOR; // default is light gray
@property (nonatomic, strong) UIColor *cancelButtonTintColor UI_APPEARANCE_SELECTOR; // default is gray
@property (nonatomic, strong) UIColor *otherButtonsTintColor UI_APPEARANCE_SELECTOR; // default is window's tint color
@property (nonatomic, strong) UIColor *destructiveButtonTintColor UI_APPEARANCE_SELECTOR; // default is red
@property (nonatomic, strong) UIColor *buttonsBackgroundColor UI_APPEARANCE_SELECTOR; // default is white with 0.95 alpha

///--------------------------------------------------
/// @name Creating an instance
///--------------------------------------------------

/**
 *  @abstract Creates and returns a new action sheet.
 *
 *  @param title                The title of the action sheet.
 *  @param cancelButtonTitle    The title of the cancel button.
 *
 *  @return A new instance of the class.
 */
- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle;

/**
 *  @abstract Creates and returns a new action sheet.
 *
 *  @param title                The title of the action sheet.
 *  @param cancelButtonTitle    The title of the cancel button.
 *  @param cancelBlock          The block to be executed when the cancel button is tapped.
 *
 *  @return A new instance of the class.
 */
- (instancetype)initWithTitle:(NSString *)title cancelButtonTitle:(NSString *)cancelButtonTitle cancelBlock:(void (^)(void))cancelBlock;

///--------------------------------------------------
/// @name Adding buttons to the action sheet
///--------------------------------------------------

/**
 *  @abstract Adds a button to the action sheet and associates to it the passed-in block.
 *
 *  @param title The title of the button to be added to the receiver.
 *
 *  @return An integer representing the index of the newly added button.
 */
- (NSUInteger)addButtonWithTitle:(NSString *)title;

/**
 *  @abstract Adds a button to the action sheet and associates to it the passed-in block.
 *
 *  @param title The title of the button to be added to the receiver.
 *  @param block The block to be executed when the button is tapped.
 *
 *  @return An integer representing the index of the newly added button.
 */
- (NSUInteger)addButtonWithTitle:(NSString *)title selectionBlock:(void (^)(void))selectionBlock;

- (void)setDestructiveButtonIndex:(NSUInteger)destructiveButtonIndex;
- (NSUInteger)addDestructiveButtonWithTitle:(NSString *)title selectionBlock:(void (^)(void))selectionBlock;

///--------------------------------------------------
/// @name Showing and Dismissing the Action Sheet
///--------------------------------------------------

- (void)show;
- (void)showInView:(UIView *)view;

- (void)dismiss;
- (void)dismissWithSelectedButtonIndex:(NSUInteger)index;

@end

#endif
