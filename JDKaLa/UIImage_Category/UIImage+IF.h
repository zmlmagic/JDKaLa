//
//  UIImage+IF.h
//  InstaFilters
//
//  Created by 张明磊 on 12-10-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (IF)

- (UIImage *)cropImageWithBounds:(CGRect)bounds;
- (UIImage *)imageRotatedByDegrees:(CGFloat)degrees;
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality;
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality;
- (CGAffineTransform)transformForOrientation:(CGSize)newSize;

@end
