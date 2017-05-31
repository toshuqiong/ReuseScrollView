//
//  ViewController.m
//  ReuseScrollView
//
//  Created by qiongshu on 2017/5/25.
//  Copyright © 2017年 qiongshu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource> {
    CGFloat height;
    BOOL lastOperateIsDelete;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *reuseArray;
@property (nonatomic, strong) NSMutableArray *visiArray;

@property (nonatomic, strong) NSMutableArray *sources;

@end

@implementation ViewController

- (void)dealloc {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-60)];
    scroll.delegate = self;
    scroll.scrollsToTop = YES;
    scroll.decelerationRate = 1.0;
    [self.view addSubview:scroll];
    self.scrollView = scroll;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-60)];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    self.reuseArray = [NSMutableArray array];
    self.visiArray = [NSMutableArray array];
    self.sources = [NSMutableArray array];
    
    height = (CGRectGetHeight(self.view.frame) - 60) / 10;
    
    for (NSInteger i = 0; i < 15; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), height)];
//        view.hidden = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((CGRectGetWidth(self.view.frame)-120)/2, (height-40)/2, 120, 40)];
        label.font = [UIFont systemFontOfSize:20];
        label.textColor = [UIColor whiteColor];
        label.tag = 1;
        [view addSubview:label];
        
        view.backgroundColor = [UIColor colorWithRed:1.0*(arc4random()%255)/255 green:1.0*(arc4random()%255)/255 blue:1.0*(arc4random()%255)/255 alpha:1.0];
//        [self.scrollView addSubview:view];
        [self.reuseArray addObject:view];
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"Add" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor blueColor]];
    btn.frame = CGRectMake((CGRectGetWidth(self.view.frame)-250)/2, 0, 120, 60);
    [btn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    UIButton *cbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cbtn setTitle:@"change" forState:UIControlStateNormal];
    [cbtn setBackgroundColor:[UIColor blueColor]];
    cbtn.frame = CGRectMake((CGRectGetWidth(self.view.frame)-250)/2+130, 0, 120, 60);
    [cbtn addTarget:self action:@selector(change:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cbtn];
    
    lastOperateIsDelete = YES;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (CGRectGetHeight(self.view.frame) - 60) / 10;;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = [@(indexPath.row) description];
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

- (void)change:(id)sender {
    self.tableView.hidden = !self.tableView.hidden;
    [self.tableView reloadData];
}

- (void)add:(id)sender {
    NSArray *arr = @[@"", @"", @"", @"", @"", @"", @"", @"", @"", @""];
    [self.sources addObjectsFromArray:arr];
    
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.view.frame), height * self.sources.count);
    
    if (self.sources.count > arr.count) {
        return ;
    }
    
    for (NSInteger i = 0; i < self.sources.count; i++) {
        UIView *view = [self.reuseArray firstObject];
        view.frame = CGRectMake(0, height*i, CGRectGetWidth(self.view.frame), height);
        
        UILabel *label = [view viewWithTag:1];
        if (label) {
            label.text = [@(i) description];
        }
        
        [self.scrollView addSubview:view];
        [self.reuseArray removeObject:view];
        [self.visiArray addObject:view];
    }
//    for (UIView *v in self.visiArray) {
//        v.hidden = NO;
//    }
//    [self.visiArray makeObjectsPerformSelector:@selector(setHidden:) withObject:@(NO)];
    
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset {
    NSLog(@"==============%@, %@, %@", NSStringFromCGPoint(velocity), NSStringFromCGPoint(*targetContentOffset), NSStringFromCGPoint(scrollView.contentOffset));
    
//    (*targetContentOffset) = CGPointMake(0, 0);
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self updateViewStatus];
}

- (void)updateViewStatus {
    
    CGFloat offsetY = self.scrollView.contentOffset.y;
    
    NSArray *tmpArray = [_visiArray copy];
//    移除已经没有显示在当前屏幕内的view
    [tmpArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *view = (UIView *)obj;
        
        CGRect frame = [self.scrollView convertRect:view.frame toView:self.view];
        
        if (!CGRectIntersectsRect(self.scrollView.frame, frame)) {
            [view removeFromSuperview];
            [_visiArray removeObject:view];
            [_reuseArray addObject:view];
        }
    }];
    
    UIView *fView = [_visiArray firstObject];
    UIView *lView = [_visiArray lastObject];
    
    CGFloat fMinY = CGRectGetMinY(fView.frame);     //第一个view在scrollview中的位置，判断顶部需要新增几个
    CGFloat lMaxY = CGRectGetMaxY(lView.frame);     //最后一个view在scrollview中的位置，判断底部需要新增几个
    double tN = ceilf((fMinY - offsetY) / height);
    double bN = ceilf((CGRectGetHeight(self.scrollView.frame) + offsetY - lMaxY) / height);
    
//    顶部新增
    for (int i = 0; i < tN; i++) {
        CGFloat y = CGRectGetMinY(fView.frame)-height;
        if (y < 0) {
            break ;
        }
        UIView *view = [_reuseArray firstObject];
        view.frame = CGRectMake(0, y, CGRectGetWidth(self.view.frame), height);
        [self.scrollView addSubview:view];
        [_visiArray insertObject:view atIndex:0];
        [_reuseArray removeObject:view];
        fView = view;
        
        UILabel *label = [view viewWithTag:1];
        if (label) {
            label.text = [@(ceil(CGRectGetMinY(view.frame) / height)) description];
        }
        
    }
    
    
//    底部新增
    for (int j = 0; j < bN; j++) {
        if (offsetY + CGRectGetHeight(self.scrollView.frame) > self.scrollView.contentSize.height) {
            break ;
        }
        UIView *view = [_reuseArray firstObject];
        view.frame = CGRectMake(0, CGRectGetMaxY(lView.frame), CGRectGetWidth(self.view.frame), height);
        [self.scrollView addSubview:view];
        [_visiArray addObject:view];
        [_reuseArray removeObject:view];
        lView = view;
        
        UILabel *label = [view viewWithTag:1];
        if (label) {
            label.text = [@(ceil(CGRectGetMinY(view.frame) / height)) description];
        }
        
    }
}

@end
