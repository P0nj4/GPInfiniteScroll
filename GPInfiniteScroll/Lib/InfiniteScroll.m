//
//  InfiniteScroll.m
//  GPCarrusel
//
//  Created by German Pereyra on 7/8/15.
//  Copyright (c) 2015 German Pereyra. All rights reserved.
//

#import "InfiniteScroll.h"
#import "infiniteItemView.h"

@interface InfiniteScroll () <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scroll;
@property (nonatomic, strong) NSArray *datasource;
@property (nonatomic) BOOL isdragging;
@property (nonatomic, weak) infiniteItemView *focusedView;
@end

@implementation InfiniteScroll

- (instancetype)initWithFrame:(CGRect)frame datasource:(NSArray *)datasource delegate:(id<InfiniteScrollDelegate>)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        self.datasource = datasource;
        self.scroll = [[UIScrollView alloc] initWithFrame:self.bounds];
        [self addSubview:self.scroll];
        self.scroll.pagingEnabled = YES;
        self.scroll.showsHorizontalScrollIndicator = NO;
        self.scroll.showsVerticalScrollIndicator = NO;
        self.scroll.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.scroll.contentSize = CGSizeMake(self.bounds.size.width * self.datasource.count, self.bounds.size.height);
        self.scroll.delegate = self;
        [self.scroll setBounces:NO];
        [self addScrollViews];
        self.scroll.contentOffset = CGPointMake(self.bounds.size.width, 0);
    }
    return self;
}

- (void)reloadData:(NSArray *)datasource {
    for (UIView *v in self.scroll.subviews) {
        [v removeFromSuperview];
    }
    self.datasource = datasource;
    [self addScrollViews];
    self.scroll.contentSize = CGSizeMake(self.bounds.size.width * self.datasource.count, self.bounds.size.height);
    self.scroll.contentOffset = CGPointMake(self.bounds.size.width, 0);

}

- (void)addScrollViews {
    for (int i = 0; i < self.datasource.count - 1; i++) {
        UIView *contentView = [self.delegate viewForContent:[self.datasource objectAtIndex:i] inFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        infiniteItemView *item = [[infiniteItemView alloc] initWithFrame:CGRectMake((i + 1) * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
        item.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [item addSubview:contentView];
        item.contentView = contentView;
        [self.scroll addSubview:item];
    }
    
    //último que lo agrego en 0 (el scroll NO esta en el punto 0)
    UIView *contentView = [self.delegate viewForContent:[self.datasource objectAtIndex:self.datasource.count - 1] inFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    infiniteItemView *item = [[infiniteItemView alloc] initWithFrame:CGRectMake(0 * self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
    item.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [item addSubview:contentView];
    item.contentView = contentView;
    [self.scroll addSubview:item];
}

#pragma mark - Public Methods
- (void)moveOneItemLeft {
    if (self.datasource.count < 3)
        return;
    if ((int)self.scroll.contentOffset.x % (int)self.bounds.size.width == 0)
        [self.scroll setContentOffset:CGPointMake(self.scroll.contentOffset.x - self.bounds.size.width, self.scroll.contentOffset.y) animated:YES];
}

- (void)moveOneItemRight {
    if (self.datasource.count < 3)
        return;
    if ((int)self.scroll.contentOffset.x % (int)self.bounds.size.width == 0)
        [self.scroll setContentOffset:CGPointMake(self.scroll.contentOffset.x + self.bounds.size.width, self.scroll.contentOffset.y) animated:YES];
}


#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!self.isdragging) {
        [self reorganizeViews];
    }
    
    if ((int)self.scroll.contentOffset.x % (int)self.bounds.size.width == 0)
        [self notifyFocusView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isdragging = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reorganizeViews];
    self.isdragging = NO;
}

-(void)reorganizeViews {
    if (self.datasource.count < 3)
        return;
    
    if (self.scroll.contentOffset.x == 0) {
        UIView *lastView = [self getLastView];
        
        NSMutableArray *orderedItems = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.scroll.subviews.count; i++) {
            UIView *v = [self viewAtIndex:i];
            if (![v isEqual:lastView]) {
                [orderedItems addObject:v];
            }
        }
        
        for (int i = 0; i < orderedItems.count; i++) {
            UIView *v = [orderedItems objectAtIndex:i];
            v.frame = CGRectMake((i+1) * v.frame.size.width, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
        }
        
        lastView.frame = CGRectMake(0, lastView.frame.origin.y, lastView.frame.size.width, lastView.frame.size.height);
        self.scroll.contentOffset = CGPointMake(self.bounds.size.width, 0);
    }
    
    if (self.scroll.contentOffset.x == self.scroll.contentSize.width - self.bounds.size.width) {
        UIView *firstView = [self viewAtIndex:0];
        
        NSMutableArray *orderedItems = [[NSMutableArray alloc] init];
        for (int i = (int)self.scroll.subviews.count - 1; i > 0; i--) {
            UIView *v = [self viewAtIndex:i];
            if (![v isEqual:firstView]) {
                [orderedItems addObject:v];
            }
        }
        
        for (int i = 0; i < orderedItems.count; i++) {
            UIView *v = [orderedItems objectAtIndex:i];
            v.frame = CGRectMake(self.scroll.contentSize.width - (((i+2) * v.frame.size.width)), v.frame.origin.y, v.frame.size.width, v.frame.size.height);
        }
        
        firstView.frame = CGRectMake(self.scroll.contentSize.width - self.bounds.size.width, firstView.frame.origin.y, firstView.frame.size.width, firstView.frame.size.height);
        self.scroll.contentOffset = CGPointMake(self.scroll.contentSize.width - (self.bounds.size.width * 2), 0);
    }
}

#pragma mark - Extra Methods
- (UIView *)getLastView {
    float lastPosX = -1;
    UIView *lastView = nil;
    for (UIView *v in self.scroll.subviews) {
        if (v.frame.origin.x > lastPosX) {
            lastPosX = v.frame.origin.x;
            lastView = v;
        }
    }
    return lastView;
}

- (UIView *)viewAtIndex:(int)index {
    for (UIView *v in self.scroll.subviews) {
        if (v.frame.origin.x == self.bounds.size.width * index) {
            return v;
        }
    }
    return nil;
}

- (void)notifyFocusView {
    for (UIView *v in self.scroll.subviews) {
        if (v.frame.origin.x == self.scroll.contentOffset.x && [v isKindOfClass:[infiniteItemView class]]) {
            if (self.focusedView)
                [self.delegate viewDidLoseFocus:self.focusedView.contentView];
            self.focusedView = ((infiniteItemView *)v);
            [self.delegate viewDidFocus:((infiniteItemView *)v).contentView];

        }
    }
}
@end
