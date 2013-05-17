//
//  RePageScrollView.h
//  PageScrollDemo
//
//  Created by Xummer on 13-5-18.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, RCPageScrollViewDirection){
    kPageScrollHorizontal = 0,
    kPageScrollVertical
};

#define CACHED_ELEMENTS         5
#define SCROLL_WITH_ANIMATION   YES

@protocol RCPageScrollViewDataSource;
@protocol RCPageScrollViewDelegate;

@interface RCPageEntry : NSObject

@property (nonatomic, strong) UIView    *pageView;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, assign) BOOL      reused;

@end


@interface RCPageScrollView : UIView <UIScrollViewDelegate>

@property (nonatomic, assign) NSInteger elementCount;
@property (nonatomic, assign) NSInteger currentPage;    // start from 0
@property (nonatomic, assign) RCPageScrollViewDirection scrollDirection;
@property (nonatomic, strong) NSMutableArray *cachedPages;


@property (nonatomic, assign) id <RCPageScrollViewDataSource> dataSource;
@property (nonatomic, assign) id <RCPageScrollViewDelegate>   pageDelegate;
@property (nonatomic, assign) id scrollViewDelegate;
@property (nonatomic, strong) UIScrollView *contentScrollView;

- (id)initWithFrame:(CGRect)frame
         dataSource:(id<RCPageScrollViewDataSource>)pDataSource
       elementCount:(NSInteger)pElementCount
          direction:(RCPageScrollViewDirection)pDirection
              cycle:(BOOL)pCycle;

- (void)updateCurrentPage:(NSInteger)newCurrentPageNumber animation:(BOOL)animation;

@end

@protocol RCPageScrollViewDataSource <NSObject>

@required

- (UIView *)scrollView:(UIScrollView *)scrollView pageAtIndex:(NSInteger)index;

- (void)scrollView:(UIScrollView *)scrollView updatePage:(UIView *)page atIndex:(NSInteger)index;

@optional

- (NSUInteger)numberOfPagesInScrollView:(UIScrollView*)scrollView;

@end

@protocol RCPageScrollViewDelegate <NSObject>

@optional

- (void)scrollView:(UIScrollView *)scrollView curentPageChanged:(NSInteger)pCurrentPage;

@end
