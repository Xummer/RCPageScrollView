# RCPageScrollView #

Xummer

![](http://tp4.sinaimg.cn/1994914167/180/5650638007/1)  
**[Follow Me On Weibo](http://weibo.com/xummers)**

## Over View ##
重用的PageScrollView, 用法类似UITableView。

## How To
1.设置DataSource
```objc
@interface ViewController () <RCPageScrollViewDataSource>
```

2.初始化
```objc
RCPageScrollView *scroll = [[RCPageScrollView alloc] initWithFrame:self.view.bounds dataSource:self elementCount:[_dataArray count] direction:kPageScrollVertical cycle:NO];
[self.view addSubview:scroll];
```

3.实现protocol
每个页面的初始化
```objc
- (UIView*)scrollView:(UIScrollView*)scrollView pageAtIndex:(NSInteger)index
```
  
重用页面的更新
```objc
- (void)scrollView:(UIScrollView *)scrollView updatePage:(UIView *)page atIndex:(NSInteger)index
```

## 以上
