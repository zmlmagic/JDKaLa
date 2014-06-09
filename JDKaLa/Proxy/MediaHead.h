//
//  MediaHead.h
//  TestProxy
//
//  Created by 韩 抗 on 13-5-28.
//  Copyright (c) 2013年 ipvd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@interface MediaHead : NSObject<ASIHTTPRequestDelegate>
{
    ASIHTTPRequest  *mHttpRequest;
    BOOL            mInited;
    int             mCurPos;
    
}
@property (readonly,nonatomic) NSString *url;
@property (readonly,nonatomic) BOOL     finishDownload;
@property (readonly,nonatomic) NSMutableData   *data;

- (id)initWithURL:(NSString*)url;
- (BOOL)getHead;
- (void)cancelGetHead;
@end
