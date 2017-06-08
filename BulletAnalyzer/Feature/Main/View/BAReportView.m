//
//  BAReportView.m
//  BulletAnalyzer
//
//  Created by 张骏 on 17/6/7.
//  Copyright © 2017年 Zj. All rights reserved.
//


#import "BAReportView.h"
#import "BAReportCell.h"
#import "BAReplyModel.h"

static NSString *const BAReportCellReusedId = @"BAReportCellReusedId";

@interface BAReportView()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UILabel *indicatorLabel;

@end

@implementation BAReportView

#pragma mark ---lifeCycle---
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor clearColor];
        
        [self setupCollectionView];
        
        [self setupIndicator];
    }
    return self;
}


#pragma mark ---public---
- (void)setReportModelArray:(NSMutableArray *)reportModelArray{
    _reportModelArray = reportModelArray;
    
    if (reportModelArray.count) {
        [_collectionView reloadData];
        [_collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:500 * reportModelArray.count inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        self.currentIndex = 500 * reportModelArray.count - 1;
        _indicatorLabel.hidden = NO;
    } else {
        _indicatorLabel.hidden = YES;
    }
}


#pragma mark ---private---
- (void)setupCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, BAScreenWidth, BAReportCellHeight) collectionViewLayout:layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.bounces = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.layer.masksToBounds = NO;
    
    [_collectionView registerClass:[BAReportCell class] forCellWithReuseIdentifier:BAReportCellReusedId];
    
    [self addSubview:_collectionView];
}


- (void)setupIndicator{
    _indicatorLabel = [UILabel lableWithFrame:CGRectMake(0, _collectionView.bottom + 4 * BAPadding, BAScreenWidth, BASmallTextFontSize) text:@"" color:BALightTextColor font:BAThinFont(BASmallTextFontSize) textAlignment:NSTextAlignmentCenter];
    
    [self addSubview:_indicatorLabel];
}


- (void)adjustImgTransformWithOffsetY:(CGFloat)offsetY{
    CGFloat index = (offsetY + 4 * BAPadding) / BAReportCellWidth;
    CGFloat deltaIndex = index - _currentIndex;
    CGFloat zoomScale = 1.1 - fabs(deltaIndex - 1) * 0.2;
    
    CGFloat leftIndex = (offsetY + 4 * BAPadding - BAReportCellWidth) / BAReportCellWidth;
    CGFloat leftDeltaIndex = leftIndex - _currentIndex;
    CGFloat leftZoomScale = fabs(leftDeltaIndex) * 0.2 + 0.9;
    
    CGFloat rightIndex = (offsetY + 4 * BAPadding + BAReportCellWidth) / BAReportCellWidth;
    CGFloat rightDeltaIndex = rightIndex - _currentIndex;
    CGFloat rightZoomScale = fabs(rightDeltaIndex - 2) * 0.2 + 0.9;
    
    [_collectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof UICollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSInteger item = [[_collectionView indexPathForCell:obj] item];
        if (item == _currentIndex + 1) { // 中间一个
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, fabs(deltaIndex - 1) * 2 * BAPadding);
            obj.transform = CGAffineTransformScale(transform, zoomScale, zoomScale);
        } else if (item == _currentIndex) { // 左边一个
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, (1 - fabs(deltaIndex - 1)) * 2 * BAPadding);
            obj.transform = CGAffineTransformScale(transform, leftZoomScale, leftZoomScale);
        } else if (item == _currentIndex + 2){ // 右边一个
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, (1 - fabs(deltaIndex - 1)) * 2 * BAPadding);
            obj.transform = CGAffineTransformScale(transform, rightZoomScale, rightZoomScale);
        }
    }];
}


- (void)setCurrentIndex:(NSInteger)currentIndex{
    _currentIndex = currentIndex;
    
    NSInteger realIndex = (_currentIndex + 1) % _reportModelArray.count;
    _indicatorLabel.text = [NSString stringWithFormat:@"%zd of %zd", realIndex + 1, _reportModelArray.count];
}


#pragma mark ---UICollectionViewDelegate---
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1000 * _reportModelArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    BAReportCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:BAReportCellReusedId forIndexPath:indexPath];
    cell.reportModel = _reportModelArray[indexPath.item % _reportModelArray.count];
    cell.transform = indexPath.item == _reportModelArray.count * 500 ? CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 0), 1.1, 1.1) : CGAffineTransformScale(CGAffineTransformMakeTranslation(0, 2 * BAPadding), 0.9, 0.9);
    
    return cell;
}

//item大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{

    return CGSizeMake(BAReportCellWidth, BAReportCellHeight);
}


#pragma mark ---UIScrollViewDelegate---
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat offsetX = _collectionView.contentOffset.x;
    
    [self adjustImgTransformWithOffsetY:offsetX];
}


//手动分页
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    
    float pageWidth = BAReportCellWidth; // width + space
    
    float currentOffset = scrollView.contentOffset.x;
    float targetOffset = targetContentOffset->x;
    float newTargetOffset = 0;
    
    if (targetOffset > currentOffset - 4 * BAPadding) {
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth; //向上取整
    } else {
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth; //向下取整
    }
    
    if (newTargetOffset < 0) {
        newTargetOffset = 0;
    } else if (newTargetOffset > scrollView.contentSize.width) {
        newTargetOffset = scrollView.contentSize.width;
    }
    
    targetContentOffset->x = currentOffset;
    
    newTargetOffset = newTargetOffset - 4 * BAPadding;
    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
    
    self.currentIndex = newTargetOffset / pageWidth;
}

@end
