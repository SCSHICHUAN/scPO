//
//  SCView.m
//  Pods
//
//  Created by AnX on 2021/1/15.
//

#import "SCView.h"

@implementation SCView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUI];
    }
}
-(void)setUI
{
    self.backgroundColor = UIColor.redColor;
}

@end
