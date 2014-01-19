//
//  GTDynamicCollectionViewFlowLayout.m
//  Carson
//
//  Created by Gianluca Tranchedone on 19/01/2014.
//  Copyright (c) 2014 Cocoa Beans GT Limited. All rights reserved.
//

#import "GTDynamicCollectionViewFlowLayout.h"

@interface GTDynamicCollectionViewFlowLayout ()

@property (assign, nonatomic) CGFloat latestDelta;
@property (strong, nonatomic) NSMutableSet *visibleIndexPathsSet;

@end


@implementation GTDynamicCollectionViewFlowLayout

#pragma mark - Superclass Methods Override -
#pragma mark Layout Preparation and Invalidation

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    CGFloat deltaY = newBounds.origin.y - self.collectionView.bounds.origin.y;
    CGFloat deltaX = newBounds.origin.x - self.collectionView.bounds.origin.x;
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    BOOL useHorizontalScrolling = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
    CGFloat delta = useHorizontalScrolling ? deltaX : deltaY;
    
    [self setLatestDelta:delta];
    [self.dynamicAnimator.behaviors enumerateObjectsUsingBlock:^(UIAttachmentBehavior *springBehaviour, NSUInteger idx, BOOL *stop) {
        UICollectionViewLayoutAttributes *attributes = [springBehaviour.items firstObject];
        attributes.center = [self centerForLayoutAttributes:attributes touchLocation:touchLocation anchorPoint:springBehaviour.anchorPoint];
        
        [self.dynamicAnimator updateItemUsingCurrentState:attributes];
    }];
    
    return NO;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    CGRect visibleRect = CGRectInset(self.collectionView.bounds, -100, -100);
    NSArray *layoutAttributesInVisibleRect = [super layoutAttributesForElementsInRect:visibleRect];
    
    [self removeNoLongerVisibleBehaviorsFromLayoutAttributes:layoutAttributesInVisibleRect];
    [self addBehaviorsToNewlyVisibleItemsFromLayoutAttributes:layoutAttributesInVisibleRect];
}

#pragma mark Layout Attributes

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [self.dynamicAnimator itemsInRect:rect];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.dynamicAnimator layoutAttributesForCellAtIndexPath:indexPath];
}

#pragma mark - Private APIs -
#pragma mark Helpers

- (void)removeNoLongerVisibleBehaviorsFromLayoutAttributes:(NSArray *)attributes
{
    NSSet *itemsIndexPathsInVisibleRectSet = [NSSet setWithArray:[attributes valueForKey:@"indexPath"]];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UIAttachmentBehavior *behavior, NSDictionary *bindings) {
        BOOL currentlyVisible = ([itemsIndexPathsInVisibleRectSet member:[[[behavior items] lastObject] indexPath]] != nil);
        return !currentlyVisible;
    }];
    
    NSArray *noLongerVisibleBehaviors = [self.dynamicAnimator.behaviors filteredArrayUsingPredicate:predicate];
    [noLongerVisibleBehaviors enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
        [self.dynamicAnimator removeBehavior:obj];
        [self.visibleIndexPathsSet removeObject:[[[obj items] lastObject] indexPath]];
    }];
}

- (void)addBehaviorsToNewlyVisibleItemsFromLayoutAttributes:(NSArray *)attributes
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(UICollectionViewLayoutAttributes *item, NSDictionary *bindings) {
        BOOL currentlyVisible = ([self.visibleIndexPathsSet member:item.indexPath] != nil);
        return !currentlyVisible;
    }];
    
    NSArray *newlyVisibleItems = [attributes filteredArrayUsingPredicate:predicate];
    CGPoint touchLocation = [self.collectionView.panGestureRecognizer locationInView:self.collectionView];
    
    [newlyVisibleItems enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attributes, NSUInteger idx, BOOL *stop) {
        UIAttachmentBehavior *springBehavior = [self springBehaviorWithLayoutAttributes:attributes];
        attributes.center = [self centerForLayoutAttributes:attributes touchLocation:touchLocation anchorPoint:springBehavior.anchorPoint];
        
        [self.visibleIndexPathsSet addObject:attributes.indexPath];
        [self.dynamicAnimator addBehavior:springBehavior];
    }];
}

#pragma mark - Public APIs -

- (UIAttachmentBehavior *)springBehaviorWithLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:attributes attachedToAnchor:attributes.center];
    springBehavior.frequency = 1.0f;
    springBehavior.damping = 0.8f;
    springBehavior.length = 0.0f;
    
    return springBehavior;
}

- (CGPoint)centerForLayoutAttributes:(UICollectionViewLayoutAttributes *)attributes touchLocation:(CGPoint)touchLocation anchorPoint:(CGPoint)anchorPoint
{
    BOOL useHorizontalScrolling = (self.scrollDirection == UICollectionViewScrollDirectionHorizontal);
    CGPoint center = attributes.center;
    CGFloat delta = self.latestDelta;
    
    if (!CGPointEqualToPoint(CGPointZero, touchLocation)) {
        CGFloat distanceFromTouch = useHorizontalScrolling ? fabsf(touchLocation.x - anchorPoint.x) : fabsf(touchLocation.y - anchorPoint.y);
        CGFloat scrollResistance = distanceFromTouch / 1500.0f;
        
        CGFloat centerAxisValue = useHorizontalScrolling ? center.x : center.y;
        centerAxisValue += (delta < 0) ? MAX(delta, (delta * scrollResistance)) : MIN(delta, (delta * scrollResistance));
        
        if (useHorizontalScrolling) {
            center.x = centerAxisValue;
        }
        else {
            center.y = centerAxisValue;
        }
    }
    
    return center;
}

#pragma mark - Setters and Getters

- (UIDynamicAnimator *)dynamicAnimator
{
    if (!_dynamicAnimator) {
        self.dynamicAnimator = [[UIDynamicAnimator alloc] initWithCollectionViewLayout:self];
    }
    return _dynamicAnimator;
}

- (NSMutableSet *)visibleIndexPathsSet
{
    if (!_visibleIndexPathsSet) {
        self.visibleIndexPathsSet = [NSMutableSet set];
    }
    return _visibleIndexPathsSet;
}

@end
