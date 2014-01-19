//
//  GTDynamicCollectionViewFlowLayout.h
//  Carson
//
//  Created by Gianluca Tranchedone on 19/01/2014.
//  Copyright (c) 2014 Cocoa Beans GT Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @abstract GTDynamicCollectionViewFlowLayout adds UIKit Dynamics to the standard UICollectionViewFlowLayout to reproduce the bouncy effect
 *  used in the Messages app on iOS 7.
 */
@interface GTDynamicCollectionViewFlowLayout : UICollectionViewFlowLayout

/**
 *  @abstract The dynamicAnimator used by the layout to animate the collectionView's cells.
 */
@property (strong, nonatomic) UIDynamicAnimator *dynamicAnimator;

/**
 *  @abstract Creates and returns a new attachmentBehavior that is used to recreate a spring effect similar to the one used in the Messages app on iOS 7.
 *  @param attributes The UICollectionViewLayoutAttributes object to which the behaviour should be attached.
 *  @return A new attachmentBehavior for the passed-in attributes.
 */
- (UIAttachmentBehavior *)springBehaviorWithLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes;

@end
