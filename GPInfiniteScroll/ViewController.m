//
//  ViewController.m
//  GPInfiniteScroll
//
//  Created by German Pereyra on 7/8/15.
//  Copyright (c) 2015 German Pereyra. All rights reserved.
//

#import "ViewController.h"
#import "InfiniteScroll.h"

@interface ViewController () <InfiniteScrollDelegate>
@property (nonatomic, strong) InfiniteScroll *scroll;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSArray *texts = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8"];
    self.scroll = [[InfiniteScroll alloc] initWithFrame:CGRectMake(10, 200, self.view.bounds.size.width - 20, 200) datasource:texts delegate:self];
    self.scroll.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.scroll];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)moveLeftPressed:(id)sender {
    [self.scroll moveOneItemLeft];
}
- (IBAction)moveRightPressed:(id)sender {
    [self.scroll moveOneItemRight];
}
- (IBAction)reloadPressed:(id)sender {
    NSArray *texts = @[@"A", @"B", @"C", @"D", @"E"];
    [self.scroll reloadData:texts];
}

- (UIView *)viewForContent:(id)content inFrame:(CGRect)frame {
    
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    
    UILabel *aView = [[UILabel alloc]initWithFrame:frame];
    aView.backgroundColor = color;
    aView.font = [UIFont systemFontOfSize:17];
    aView.layer.masksToBounds = YES;
    aView.textColor = [UIColor whiteColor];
    aView.textAlignment = NSTextAlignmentCenter;
    aView.text = content;
    return aView;
}

- (void)viewDidLoseFocus:(UIView *)view {
    UILabel *aView = (UILabel *)view;
    aView.font = [UIFont systemFontOfSize:17];
}

- (void)viewDidFocus:(UIView *)view {
    UILabel *aView = (UILabel *)view;
    aView.font = [UIFont boldSystemFontOfSize:30];
}

@end
