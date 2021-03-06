//
//  ViewController.m
//  PageScrollDemo
//
//  Created by Xummer on 13-5-15.
//  Copyright (c) 2013年 Xummer. All rights reserved.
//

#import "ViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "RCPageScrollView.h"

@interface ViewController () <RCPageScrollViewDataSource>
@property (nonatomic, strong) RCPageScrollView *pageScroll;
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self setupPageScrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupPageScrollView
{    
    [self randomDataArray];
    
    RCPageScrollView *scroll = [[RCPageScrollView alloc] initWithFrame:self.view.bounds dataSource:self elementCount:[_dataArray count] direction:kPageScrollVertical cycle:YES];
    self.pageScroll = scroll;
    [self.view addSubview:scroll];
}

- (IBAction)buttonAction:(id)sender
{
    [self randomDataArray];
    [self.pageScroll reloadData];
//    [_pageScroll setCurrentPage:--_pageScroll.currentPage];
}

- (void)randomDataArray {
    
    NSMutableArray *mArr = [NSMutableArray array];
    
    int iRandomBase = arc4random() % 100;
    
    int iRandomCount = arc4random() % 26 + 1;
    
    
    for (int i = 0; i < iRandomCount; i++) {
        [mArr addObject:[NSString stringWithFormat:@"%d", i + iRandomBase]];
    }
    
    self.dataArray = mArr;
}

#pragma mark - 
#pragma mark - PageScrollView DataSource
//generate the page at specified index
- (UIView*)scrollView:(UIScrollView*)scrollView pageAtIndex:(NSInteger)index
{
    //    CGRect frame = CGRectInset(self.view.bounds, 10+index, 10+index);
    //    CGRect frame = self.view.bounds;
    CGRect frame = CGRectInset(self.view.bounds, 10, 10);
    UIView *newPage = [[UIView alloc] initWithFrame:frame];
    [newPage.layer setCornerRadius:3.0f];
    [newPage setClipsToBounds:YES];
    [newPage setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *label = [[UILabel alloc] initWithFrame:newPage.bounds];
    [label setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:26]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setText:_dataArray[index]];
    [label setTag:26];
    [newPage addSubview:label];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, newPage.bounds.size.width, 44)];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundColor:[UIColor lightGrayColor]];
    [newPage addSubview:button];
        
    return newPage;
}

//update the page at specified index
- (void)scrollView:(UIScrollView *)scrollView updatePage:(UIView *)page atIndex:(NSInteger)index
{
    //    CGRect frame = CGRectInset(self.view.bounds, 10+index, 10+index);
    //    CGRect frame = self.view.bounds;
    CGRect frame = CGRectInset(self.view.bounds, 10, 10);
    [page setFrame:frame];
    
    UIView *subview = [page viewWithTag:26];
    if (subview && [subview isKindOfClass:[UILabel class]]) {
        [(UILabel *)subview setText:_dataArray[index]];
    }
}

- (NSUInteger)numberOfPagesInScrollView:(UIScrollView*)scrollView {
    return [_dataArray count];
}

@end
