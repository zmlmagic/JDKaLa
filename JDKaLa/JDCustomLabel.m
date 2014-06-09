//
//  JDCustomLabel.m
//  JDKaLa
//
//  Created by zhangminglei on 10/22/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import "JDCustomLabel.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>
#import <CoreText/CoreText.h>

#define kGradientSize       0.45f
#define kAnimationDuration  2.25f
#define kGradientTint       [UIColor whiteColor]

#define kAnimationKey       @"gradientAnimation"

@implementation JDCustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initializeLayers];
    }
    return self;
}

- (void)dealloc
{
    //[_textLayer release],_textLayer = nil;
    [super dealloc];
}


- (void)initializeLayers
{
    self.tint               = kGradientTint;
    self.animationDuration  = kAnimationDuration;
    self.gradientWidth      = kGradientSize;
    
    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
    gradientLayer.backgroundColor   = [super.textColor CGColor];
    gradientLayer.startPoint        = CGPointMake(-self.gradientWidth, 0.);
    gradientLayer.endPoint          = CGPointMake(0., 0.);
    gradientLayer.colors            = [NSArray arrayWithObjects:(id)[self.textColor CGColor],(id)[self.tint CGColor], (id)[self.textColor CGColor], nil];
    
    _textLayer                      = [CATextLayer layer];
    _textLayer.backgroundColor      = [[UIColor clearColor] CGColor];
    _textLayer.contentsScale        = [[UIScreen mainScreen] scale];
    _textLayer.rasterizationScale   = [[UIScreen mainScreen] scale];
    _textLayer.bounds               = self.bounds;
    _textLayer.anchorPoint          = CGPointZero;
    
    [self setFont:          super.font];
    [self setTextAlignment: super.textAlignment];
    [self setText:          super.text];
    [self setTextColor:     super.textColor];

    gradientLayer.mask = _textLayer;
}

-(UIColor *)textColor
{
    return [UIColor colorWithCGColor:self.layer.backgroundColor];
}

-(void) setTextColor:(UIColor *)textColor
{
    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
    gradientLayer.backgroundColor   = [textColor CGColor];
    gradientLayer.colors            = [NSArray arrayWithObjects:(id)[textColor CGColor],(id)[self.tint CGColor], (id)[textColor CGColor], nil];
    
    [self setNeedsDisplay];
}

-(NSString *)text
{
    return _textLayer.string;
}

- (void)setText:(NSString *)text
{
    _textLayer.string = text;
    [self setNeedsDisplay];
}

-(UIFont *)font
{
    CTFontRef ctFont    = _textLayer.font;
    NSString *fontName  = (__bridge NSString *)CTFontCopyName(ctFont, kCTFontPostScriptNameKey);
    CGFloat fontSize    = CTFontGetSize(ctFont);
    return [UIFont fontWithName:fontName size:fontSize];
}

-(void)setFont:(UIFont *)font
{
    CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)(font.fontName), font.pointSize, &CGAffineTransformIdentity);
    _textLayer.font = fontRef;
    _textLayer.fontSize = font.pointSize;
    CFRelease(fontRef);
    [self setNeedsDisplay];
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}


#pragma mark - UILabel Layer override

+ (Class)layerClass
{
    return [CAGradientLayer class];
}

/* Stop UILabel from drawing because we are using a CATextLayer for that! */
- (void)drawRect:(CGRect)rect {}

#pragma mark - Utility Methods

- (NSTextAlignment)textAlignment
{
    return [JDCustomLabel UITextAlignmentFromCAAlignment:_textLayer.alignmentMode];
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
    _textLayer.alignmentMode = [JDCustomLabel CAAlignmentFromUITextAlignment:textAlignment];
}

+ (NSString *)CAAlignmentFromUITextAlignment:(NSTextAlignment )textAlignment
{
    switch (textAlignment)
    {
        case NSTextAlignmentLeft:   return kCAAlignmentLeft;
        case NSTextAlignmentCenter: return kCAAlignmentCenter;
        case NSTextAlignmentRight:  return kCAAlignmentRight;
        default:                    return kCAAlignmentNatural;
    }
}

+ (NSTextAlignment )UITextAlignmentFromCAAlignment:(NSString *)alignment
{
    if ([alignment isEqualToString:kCAAlignmentLeft])       return NSTextAlignmentLeft;
    if ([alignment isEqualToString:kCAAlignmentCenter])     return NSTextAlignmentCenter;
    if ([alignment isEqualToString:kCAAlignmentRight])      return NSTextAlignmentRight;
    if ([alignment isEqualToString:kCAAlignmentNatural])    return NSTextAlignmentLeft;
    return NSTextAlignmentLeft;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    _textLayer.frame = self.layer.bounds;
}

- (void)setTint:(UIColor *)tint
{
    _tint = tint;
    CAGradientLayer *gradientLayer  = (CAGradientLayer *)self.layer;
    gradientLayer.colors            = [NSArray arrayWithObjects:(id)[self.textColor CGColor],(id)[_tint CGColor], (id)[self.textColor CGColor], nil];
    [self setNeedsDisplay];
}

- (void)startAnimating
{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    if([gradientLayer animationForKey:kAnimationKey] == nil)
    {
        CABasicAnimation *startPointAnimation = [CABasicAnimation animationWithKeyPath:@"startPoint"];
        startPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 0)];
        startPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CABasicAnimation *endPointAnimation = [CABasicAnimation animationWithKeyPath:@"endPoint"];
        endPointAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(1+self.gradientWidth, 0)];
        endPointAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = [NSArray arrayWithObjects:startPointAnimation, endPointAnimation, nil];
        group.duration = self.animationDuration;
        group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        group.repeatCount = FLT_MAX;
        [gradientLayer addAnimation:group forKey:kAnimationKey];
    }
}


- (void)stopAnimating
{
    CAGradientLayer *gradientLayer = (CAGradientLayer *)self.layer;
    if([gradientLayer animationForKey:kAnimationKey])
    {
        [gradientLayer removeAnimationForKey:kAnimationKey];
    }
}


@end



