//
//  BMCarouselView.m
//  BMCarouselView
//
//  Created by 李志强 on 2017/5/23.
//  Copyright © 2017年 Li Zhiqiang. All rights reserved.
//

#import "BMCarouselView.h"
#import "BMCarouselCollectionViewFlowLayout.h"
#import "BMCarouselCollectionViewCell.h"

#define WEAKSELF() __weak __typeof(&*self)weakSelf = self

static NSString *kCellIdentifier = @"CellIdentifier";
static const NSUInteger kTotalItems = 100;
static const NSUInteger kTotalPages = 4;
static const CGFloat kLineSpacing = 20;   //图片之间的空隙
static const CGFloat kAspectRatio = 1.37; //图片宽高比，宽/高

@interface BMCarouselView () <UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, assign) NSInteger centerItem;
@property (nonatomic, assign) NSInteger currentIndexPathRow;

@end

@implementation BMCarouselView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self configUI];
    }
    return self;
}

#pragma mark init UI

- (void)configUI {
    self.backgroundColor = [UIColor clearColor];
    BMCarouselCollectionViewFlowLayout *layout = [[BMCarouselCollectionViewFlowLayout alloc] init];
    
    CGFloat collectionViewHeight =
    ceil((self.frame.size.width - kLineSpacing * 2) / 1.2 / kAspectRatio); //图片宽度+2个空隙+2个图片宽度的10% = ScreenWidth;
    self.collectionView =
    [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, collectionViewHeight) collectionViewLayout:layout];
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[BMCarouselCollectionViewCell class]
            forCellWithReuseIdentifier:kCellIdentifier];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.decelerationRate = 0.1f;
    
    self.centerItem = kTotalItems / 2;
    for (NSInteger i = self.centerItem; i < self.centerItem + kTotalPages; i++) {
        if (0 == i % kTotalPages) {
            self.centerItem = i;
            break;
        }
    }
    self.currentIndexPathRow = self.centerItem;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndexPathRow inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                        animated:NO];
    

    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.numberOfPages = kTotalPages;
    CGRect pageControlFrame = self.pageControl.frame;
    pageControlFrame.origin.x = (self.frame.size.width - pageControlFrame.size.width) / 2;
    pageControlFrame.origin.y = collectionViewHeight + 10;
    self.pageControl.frame = pageControlFrame;
    [self addSubview:self.pageControl];

}

#pragma mark UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return kTotalItems;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BMCarouselCollectionViewCell *cell =
    [collectionView dequeueReusableCellWithReuseIdentifier:kCellIdentifier forIndexPath:indexPath];
    [cell configWithImage:[NSString stringWithFormat:@"introduce_%ld.jpg", indexPath.item % kTotalPages]];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"click : %ld",indexPath.row % kTotalPages);
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint pInView = [self convertPoint:self.collectionView.center toView:self.collectionView];
    // 获取这一点的indexPath
    NSIndexPath *indexPathNow = [self.collectionView indexPathForItemAtPoint:pInView];
    
    //判断滚动到尽头，转到中部
    [self backToCenterFromCurrentRow:indexPathNow.row];
    
    // 赋值给记录当前坐标的变量
    self.pageControl.currentPage = indexPathNow.row % kTotalPages;
    [self.pageControl updateCurrentPageDisplay];
    self.currentIndexPathRow = indexPathNow.row;
    //[self.timer setFireDate:[NSDate dateWithTimeInterval:3 sinceDate:[NSDate dateNow]]];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    //[self.timer setFireDate:[NSDate distantFuture]];
}

//判断滚动到尽头，转到中部
- (void)backToCenterFromCurrentRow:(NSInteger)currentRow {
    if (currentRow <= kTotalPages || currentRow >= kTotalItems - kTotalPages) {
        NSInteger currentItem = currentRow % kTotalPages;
        self.currentIndexPathRow = self.centerItem + currentItem;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndexPathRow inSection:0]
                                    atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally
                                            animated:NO];
    }
}

@end
