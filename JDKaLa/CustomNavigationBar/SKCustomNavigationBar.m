//
//  SKCustomNavigationBar.m
//  Gastrosoph
//
//  Created by 张明磊 on 12-10-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SKCustomNavigationBar.h"
#import <QuartzCore/QuartzCore.h>


@implementation SKCustomNavigationBar



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        // Initialization code
        //_image_background = [UIImage  imageNamed:@"image_title.png"];
        self.image_background = [self didLoadImageNotCached:@"title_bar_bg.png"];
        self.tintColor = [UIColor colorWithRed:46.0 / 255.0 green:149.0 / 255.0 blue:206.0 / 255.0 alpha:1.0];
        // draw shadow
        self.layer.masksToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 6);
        self.layer.shadowOpacity = 0.6;
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.bounds].CGPath;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    [self.image_background drawInRect:rect];
}

- (UIImage *)didLoadImageNotCached:(NSString *)filename
{
    NSString *imageFile = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle] resourcePath], filename];
    NSData *imageData = [NSData dataWithContentsOfFile:imageFile];
    return [UIImage imageWithData:imageData];
}



- (void)dealloc
{
    [_image_background release], _image_background = nil;
    [super dealloc];
}

@end
