//
//  ViewController1.m
//  ReuseScrollView
//
//  Created by shuqiong on 2017/5/31.
//  Copyright © 2017年 qiongshu. All rights reserved.
//

#import "ViewController1.h"

@interface ViewController1 () <UIScrollViewDelegate> {
    CGFloat width;
    BOOL lastOperateIsDelete;
    CGFloat padding;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *reuseArray;
@property (nonatomic, strong) NSMutableArray *visiArray;

@property (nonatomic, strong) NSMutableArray *sources;
@end

@implementation ViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    padding = 10;
    
    UIScrollView *scroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 60, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-60)];
    scroll.delegate = self;
    scroll.scrollsToTop = YES;
    scroll.decelerationRate = 1.0;
    [self.view addSubview:scroll];
    self.scrollView = scroll;
    
    self.reuseArray = [NSMutableArray array];
    self.visiArray = [NSMutableArray array];
    self.sources = [NSMutableArray array];
    
    width = (CGRectGetWidth(self.view.frame) - 10 * padding) / 10;
    
    for (NSInteger i = 0; i < 15; i++) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, CGRectGetHeight(self.scrollView.frame))];
        //        view.hidden = YES;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 80, width, 40)];
        label.textAlignment = NSTextAlignmentCenter;
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
    btn.frame = CGRectMake((CGRectGetWidth(self.view.frame)-120)/2, 0, 120, 60);
    [btn addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)add:(id)sender {
    NSArray *arr = @[@"", @"", @"", @"", @"", @"", @"", @"", @"", @""];
    [self.sources addObjectsFromArray:arr];
    
    self.scrollView.contentSize = CGSizeMake(width * self.sources.count, CGRectGetHeight(self.scrollView.frame));
    
    if (self.sources.count > arr.count) {
        return ;
    }
    
    for (NSInteger i = 0; i < self.sources.count; i++) {
        UIView *view = [self.reuseArray firstObject];
        view.frame = CGRectMake(width*i+padding*(i+1), 0, width, CGRectGetHeight(self.scrollView.frame));
        
        UILabel *label = [view viewWithTag:1];
        if (label) {
            label.text = [@(i) description];
        }
        
        [self.scrollView addSubview:view];
        [self.reuseArray removeObject:view];
        [self.visiArray addObject:view];
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self updateViewStatus];
}

- (void)updateViewStatus {
    
    {
        
        CGFloat offsetX = self.scrollView.contentOffset.x;
        
        NSArray *tmpArray = [_visiArray copy];
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
        
        CGFloat fMinX = CGRectGetMinX(fView.frame);
        CGFloat lMaxX = CGRectGetMaxX(lView.frame);
        double tN = ceilf((fMinX - offsetX) / width);
        double bN = ceilf((CGRectGetWidth(self.scrollView.frame) + offsetX - lMaxX) / width);
        
        for (int i = 0; i < tN; i++) {
            CGFloat x = CGRectGetMinX(fView.frame) - width - padding;
            if (x < 0) {
                break ;
            }
            UIView *view = [_reuseArray firstObject];
            view.frame = CGRectMake(x, 0, width, CGRectGetHeight(self.scrollView.frame));
            [self.scrollView addSubview:view];
            [_visiArray insertObject:view atIndex:0];
            [_reuseArray removeObject:view];
            fView = view;
            
            UILabel *label = [view viewWithTag:1];
            if (label) {
                label.text = [@(ceil(CGRectGetMinX(view.frame) / width)) description];
            }
        }
        
        for (int i = 0; i < bN; i++) {
            if (offsetX + CGRectGetWidth(self.scrollView.frame) > self.scrollView.contentSize.width) {
                break ;
            }
            UIView *view = [_reuseArray firstObject];
            view.frame = CGRectMake(CGRectGetMaxX(lView.frame) + padding, 0, width, CGRectGetHeight(self.scrollView.frame));
            [self.scrollView addSubview:view];
            [_visiArray addObject:view];
            [_reuseArray removeObject:view];
            lView = view;
            
            UILabel *label = [view viewWithTag:1];
            if (label) {
                label.text = [@(ceil(CGRectGetMinX(view.frame) / width)) description];
            }
        }
    }
}

@end
