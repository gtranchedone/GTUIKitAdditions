//
//  GTDynamicCollectionViewController.m
//  GTUIKitAdditionsDemo
//
//  Created by Gianluca Tranchedone on 19/01/2014.
//  Copyright (c) 2014 Gianluca Tranchedone. All rights reserved.
//

#import "GTDynamicCollectionViewController.h"

@implementation GTDynamicCollectionViewController

- (id)init
{
    GTDynamicCollectionViewFlowLayout *layout = [[GTDynamicCollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(100.0f, 100.0f);
    layout.minimumInteritemSpacing = 5.0f;
    layout.minimumLineSpacing = 5.0f;
    
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.collectionView setBackgroundColor:[UIColor whiteColor]];
	[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

#pragma mark - Private APIs -

- (void)toggleHorizontalLayout
{
    GTDynamicCollectionViewFlowLayout *layout = (id)self.collectionView.collectionViewLayout;
    if (layout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    else {
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    }
    
    [layout invalidateLayout];
}

#pragma mark - UICollectionViewDataSource -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor colorWithRed:((arc4random() % 255) / 255.0f)
                                           green:((arc4random() % 255) / 255.0f)
                                            blue:((arc4random() % 255) / 255.0f)
                                           alpha:1.0f];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self toggleHorizontalLayout];
}

@end
