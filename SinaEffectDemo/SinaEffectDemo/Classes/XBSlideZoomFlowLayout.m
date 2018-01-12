//
//  XBSlideZoomFlowLayout.m
//  SinaEffectDemo
//
//  Created by xiabob on 2018/1/12.
//  Copyright © 2018年 xiabob. All rights reserved.
//

#import "XBSlideZoomFlowLayout.h"

@implementation XBSlideZoomFlowLayout


- (void)prepareLayout {
    [super prepareLayout];
    
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    //滑动的过程中需要调整cell的缩放
    return YES;
}

- (nullable NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray<__kindof UICollectionViewLayoutAttributes *> *attributes = [[super layoutAttributesForElementsInRect:rect] copy];
    
    //collectionView中心位置
    CGFloat centerX = CGRectGetMidX(self.collectionView.bounds);
    for (UICollectionViewLayoutAttributes *attrs in attributes) {
        CGFloat offset = attrs.center.x - centerX;
        CGFloat absOffset = fabs(offset);
        
        //根据cell与中心点间的间距来缩放大小
        CGFloat calculateScale = 1 - absOffset / (self.collectionView.bounds.size.width * 2);
        CGFloat scale = MAX(calculateScale , 0.01);
        attrs.transform = CGAffineTransformMakeScale(scale, scale);
//        attrs.size = CGSizeMake(attrs.size.width * scale, attrs.size.height * scale);
        
        attrs.zIndex = -absOffset;
        
        CGFloat x = attrs.center.x - offset * 0.3;
        attrs.center = CGPointMake(x, attrs.center.y);
    }
    
    return attributes;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity {
    
    // 计算出最终显示的矩形框
    CGRect targetBounds = CGRectMake(proposedContentOffset.x, proposedContentOffset.y, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    NSArray<__kindof UICollectionViewLayoutAttributes *> *attributes = [[super layoutAttributesForElementsInRect:targetBounds] copy];
    if (attributes == nil) {
        return [super targetContentOffsetForProposedContentOffset:proposedContentOffset withScrollingVelocity:velocity];
    }
    
    //计算最终collectionView的中心位置
    CGFloat center = CGRectGetMidX(targetBounds);
    
    //找到距离中心点最近的cell对应的item
    CGFloat minOffset = CGFLOAT_MAX;
    for (UICollectionViewLayoutAttributes *attrs in attributes) {
        if (fabs(minOffset) > fabs(attrs.center.x - center)) {
            minOffset = attrs.center.x - center;
        }
    }
    
    return CGPointMake(proposedContentOffset.x + minOffset, proposedContentOffset.y);
}

@end
