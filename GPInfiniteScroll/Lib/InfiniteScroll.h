//
//  InfiniteScroll.h
//  GPCarrusel
//
//  Created by German Pereyra on 7/8/15.
//  Copyright (c) 2015 German Pereyra. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InfiniteScrollDelegate <NSObject>
- (void)viewDidFocus:(UIView *)view;
- (void)viewDidLoseFocus:(UIView *)view;
- (UIView *)viewForContent:(id)content inFrame:(CGRect)frame;
@end

@interface InfiniteScroll : UIView
@property (nonatomic, weak) id<InfiniteScrollDelegate> delegate;
- (void)moveOneItemLeft;
- (void)moveOneItemRight;
- (instancetype)initWithFrame:(CGRect)frame datasource:(NSArray *)datasource delegate:(id<InfiniteScrollDelegate>)delegate;
@end
