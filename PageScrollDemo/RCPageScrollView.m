//
//  RePageScrollView.m
//  PageScrollDemo
//
//  Created by Xummer on 13-5-18.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import "RCPageScrollView.h"

@implementation RCPageEntry

@end

@interface RCPageScrollView ()
{
    NSInteger   _cachedElementCount;
    NSInteger   _cacheStart;
    NSInteger   _cacheEnd;
}

- (void)setupSubViews;
- (void)calculateCacheRange;
- (void)rearrangePages;
- (void)setupPageAtIndex:(NSInteger)index withRecycledPages:(NSMutableArray *)recycledPages;

@end

@implementation RCPageScrollView
  
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
         dataSource:(id<RCPageScrollViewDataSource>)pDataSource
       elementCount:(NSInteger)pElementCount
          direction:(RCPageScrollViewDirection)pDirection
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
        
        _scrollDirection = pDirection;
                
        [self setElementCount:pElementCount];
        [self setDataSource:pDataSource];
        
    }
    return self;
}

- (void)setupSubViews {
    _cachedElementCount = CACHED_ELEMENTS;
    [self setCachedPages:[NSMutableArray arrayWithCapacity:_cachedElementCount]];
    
    [self setClipsToBounds:YES];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    [scrollView setShowsHorizontalScrollIndicator:NO];
    [scrollView setShowsVerticalScrollIndicator:NO];
    [scrollView setPagingEnabled:YES];
    [scrollView setClipsToBounds:YES];
    [scrollView setBackgroundColor:[UIColor clearColor]];
    [scrollView setDelegate:self];
    
    [self setContentScrollView:scrollView];
    [self addSubview:_contentScrollView];    
}

- (void)calculateCacheRange {
    NSInteger halfCache = _cachedElementCount / 2;
    
    _cacheStart = _currentPage - halfCache;
    _cacheEnd   = _currentPage + halfCache;
    
    if (_cacheStart < 0) {
        _cacheEnd  += -_cacheStart;
        _cacheStart = 0;
    }
    
    if (_cacheEnd >= _elementCount) {
        _cacheStart -= _cacheEnd - (_elementCount - 1);
        _cacheEnd = _elementCount - 1;
    }
    
    if (_cacheStart < 0) {
        _cacheStart = 0;
    }
}

- (void)rearrangePages {
    [self calculateCacheRange];
    
    NSMutableArray *recycledPages = [NSMutableArray arrayWithCapacity:_cachedElementCount];
    
    for (RCPageEntry *entry in _cachedPages) {
        if (entry.index < _cacheStart || entry.index > _cacheEnd) {
            [recycledPages addObject:entry];
        }else{
            entry.reused = YES;
        }
    }
    
    [_cachedPages removeObjectsInArray:recycledPages];
    
    if ([_cachedPages count] > 0) {
        NSInteger leftEnd    = [(RCPageEntry *)_cachedPages[0] index] - 1;
        NSInteger rightStart = [(RCPageEntry *)[_cachedPages lastObject] index] + 1;
        
        NSInteger index = _cacheStart;
        
        while (index <= leftEnd) {
            [self setupPageAtIndex:index withRecycledPages:recycledPages];
            index ++;
        }
        
        index = rightStart;
        while (index <= _cacheEnd) {
            [self setupPageAtIndex:index withRecycledPages:recycledPages];
            index ++;
        }
    }else{
        for (NSInteger index = _cacheStart; index <= _cacheEnd; index++) {
            [self setupPageAtIndex:index withRecycledPages:recycledPages];
        }
    }
    
    //remove unnecessary views
    //ensure there is no unnecessary view in the scrollview
    for (RCPageEntry *aRecycledEntry in recycledPages) {
        if (aRecycledEntry.pageView.superview != nil) {
            [aRecycledEntry.pageView removeFromSuperview];
        }
    }
    
    [recycledPages removeAllObjects];
    
    for (NSInteger index = 0; index < [_cachedPages count]; index++) {
        RCPageEntry *pageEntry = _cachedPages[index];
        if (!pageEntry.reused) {
            
            CGPoint center = CGPointMake(_contentScrollView.bounds.size.width*0.5f, _contentScrollView.bounds.size.height*0.5f);
            
            /*
             *  If pageView.size is bigger than _contentScrollView.bounds.size,
             *  the pages in _contentScrollView will looks strange.
             *  So do not do this.
             */
            
            if (_scrollDirection == kPageScrollHorizontal) {
                center.x = _contentScrollView.bounds.size.width * (pageEntry.index + 0.5f);
            }else{
                center.y = _contentScrollView.bounds.size.height * (pageEntry.index + 0.5f);
            }
            
            [pageEntry.pageView setCenter:center];
            if (pageEntry.pageView.superview == nil) {
                [_contentScrollView addSubview:pageEntry.pageView];
            }
        }
        pageEntry.reused = NO;
    }
}

- (void)setupPageAtIndex:(NSInteger)index withRecycledPages:(NSMutableArray *)recycledPages {
    if ([recycledPages count] > 0) {
        RCPageEntry *recycledEntry = [recycledPages lastObject];
        recycledEntry.index = index;
        
        if ([_dataSource respondsToSelector:@selector(scrollView:updatePage:atIndex:)]) {
            [_dataSource scrollView:_contentScrollView updatePage:recycledEntry.pageView atIndex:index];
        }
        
        [_cachedPages addObject:recycledEntry];
        [recycledPages removeLastObject];
    }else{
        RCPageEntry *newEntry = [[RCPageEntry alloc] init];
        newEntry.index = index;
        
        if ([_dataSource respondsToSelector:@selector(scrollView:pageAtIndex:)]) {
            newEntry.pageView = [_dataSource scrollView:_contentScrollView pageAtIndex:index];
        }
        
        [_cachedPages addObject:newEntry];
    }
    
}

- (void)updateCurrentPage:(NSInteger)newCurrentPageNumber animation:(BOOL)animation
{
    if (newCurrentPageNumber >= _elementCount || newCurrentPageNumber < 0) return;
    if (_scrollDirection == kPageScrollHorizontal) {
        CGFloat pageWidth = _contentScrollView.bounds.size.width;
        [_contentScrollView setContentOffset:CGPointMake(newCurrentPageNumber * pageWidth, _contentScrollView.contentOffset.y) animated:animation];
        
    } else {
        CGFloat pageHeight = _contentScrollView.bounds.size.height;
        [_contentScrollView setContentOffset:CGPointMake(_contentScrollView.contentOffset.x, newCurrentPageNumber * pageHeight) animated:animation];
    }
    
    [self scrollViewDidScroll:_contentScrollView];
}

#pragma mark - Setters
- (void)setElementCount:(NSInteger)elementCount {
    _elementCount = elementCount;
    [_contentScrollView setContentSize:_scrollDirection == kPageScrollHorizontal
                                      ?CGSizeMake(_elementCount*_contentScrollView.bounds.size.width, _contentScrollView.bounds.size.height)
                                      :CGSizeMake(_contentScrollView.bounds.size.width, _elementCount*_contentScrollView.bounds.size.height)];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    [self updateCurrentPage:currentPage animation:NO];
}

- (void)setDataSource:(id<RCPageScrollViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    if ([_dataSource respondsToSelector:@selector(numberOfPagesInScrollView:)]) {
        [self setElementCount:[_dataSource numberOfPagesInScrollView:_contentScrollView]];
    }
    
    [self rearrangePages];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self pointInside:point withEvent:event]) {
        CGPoint pointInScroll = [self convertPoint:point toView:_contentScrollView];
        if ([_contentScrollView pointInside:pointInScroll withEvent:event]) {
            return [_contentScrollView hitTest:pointInScroll withEvent:event];
        }
        
        return _contentScrollView;
    }
    
    return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int newPage = 0;
    
    if (_scrollDirection == kPageScrollHorizontal) {
        CGFloat pageWidth = scrollView.frame.size.width;
        newPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    } else {
        CGFloat pageHeight = scrollView.frame.size.height;
        newPage = floor((scrollView.contentOffset.y - pageHeight / 2) / pageHeight) + 1;
    }
    
    if (newPage != _currentPage) {
        _currentPage = newPage;
        [self rearrangePages];
        
        if ([_pageDelegate respondsToSelector:@selector(scrollView:curentPageChanged:)]) {
            [_pageDelegate scrollView:scrollView curentPageChanged:_currentPage];
        }
    }
    
    if ([_scrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [_scrollViewDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [(id<UIScrollViewDelegate>)_scrollViewDelegate scrollViewDidScroll:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([_scrollViewDelegate conformsToProtocol:@protocol(UIScrollViewDelegate)] &&
        [_scrollViewDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [(id<UIScrollViewDelegate>)_scrollViewDelegate scrollViewWillBeginDragging:scrollView];
    }
}


@end
