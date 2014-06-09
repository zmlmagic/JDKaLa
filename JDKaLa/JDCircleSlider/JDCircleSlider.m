//
//  JDCircleSlider.m
//  JDKaLa
//
//  Created by zhangminglei on 8/20/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDCircleSlider.h"

/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

/** Parameters **/
#define TB_SAFEAREA_PADDING 40


#pragma mark - Private -
@interface JDCircleSlider()
{
    int radius;
}
@end

@implementation JDCircleSlider

-(id)initWithFrame:(CGRect)frame
{
    
    self = [super initWithFrame:frame];
    if(self)
    {
        self.opaque = NO;
        //Define the circle radius taking into account the safe area
        radius = self.frame.size.width/2 - TB_SAFEAREA_PADDING;
        //Initialize the Angle at 0
        self.angle = 0;
    }
    return self;
}

-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /** Draw the Background **/
    
    //Create the path
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, M_PI *2, 0);
    
    //Set the stroke color to black
    [[UIColor blackColor]setStroke];
    
    //Define line width and cap
    CGContextSetLineWidth(ctx, TB_BACKGROUND_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    //draw it!
    //CGContextDrawPath(ctx, kCGPathStroke);
    
    //** Draw the circle (using a clipped gradient) **/
    
    /** Create THE MASK Image **/
    UIGraphicsBeginImageContext(CGSizeMake(TB_SLIDER_SIZE,TB_SLIDER_SIZE));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(imageCtx, self.frame.size.width/2  , self.frame.size.height/2, radius, 0, ToRad(self.angle), 0);
    //[[UIColor redColor]set];
    
    //Use shadow to create the Blur effect
    //CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 0), self.angle/20, [UIColor blackColor].CGColor);
    
    //define the path
    CGContextSetLineWidth(imageCtx, TB_LINE_WIDTH);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    /** Clip Context to the mask **/
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    /** THE GRADIENT **/
    
    //list of components
    CGFloat components[8] = {
        243.0/255.0, 146.0/255.0, 191.0/255.0, 1.0,
        114.0/255.0, 191.0/255.0, 251.0/255.0, 1.0};
    // Start color - Blue
    // End color - Violet
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(ctx);
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //Draw the outside light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius+TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw the inner light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius-TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
}

- (void)setProgressWithAngle:(float)progress
{
    self.angle = (int)(progress/100.0 * 360);
    
    /**
     重新绘制
     **/
    [self setNeedsDisplay];
}



@end
