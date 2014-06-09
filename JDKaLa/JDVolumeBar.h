//
//  JDVolumeBar.h
//  JDKaLa
//
//  Created by zhangminglei on 8/7/13.
//  Copyright (c) 2013 zhangminglei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JDVolumeBar : UIControl
{
@private
    NSInteger _minimumVolume;
    NSInteger _maximumVolume;
    
    NSInteger _currentVolume;
}
@property (nonatomic, assign) NSInteger currentVolume;

- (id)initWithFrame:(CGRect)frame minimumVolume:(NSInteger)minimumVolume maximumVolume:(NSInteger)maximumVolume;

@end
