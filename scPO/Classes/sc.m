//
//  sc.m
//  cc
//
//  Created by Stan on 2021/1/17.
//

#import "sc.h"

@implementation sc

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self  set];
    }
    return self;
}
-(void)set
{
    self.backgroundColor = UIColor.redColor;
    self.bounds = [ui mainScreen].bounds;
    UILabel *lab = [[UILabel alloc] initWithFrame:self.bounds];
    [self addSubview:lab];
    lab.font = [UIFont boldSystemFontOfSize:60];
    lab.text = @"欢迎使用Stan Pod库";
    lab.textAlignment = NSTextAlignmentCenter;
}
@end
