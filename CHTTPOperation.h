//
//  CHTTPOperation.h
//  NetworkSDK
//
//  Created by Cailiang on 14-9-16.
//  Copyright (c) 2014年 Cailiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CHTTPRequest.h"

@interface CHTTPOperation : NSOperation

- (id)initWithRequest:(NSURLRequest *)request callback:(RequestCallback)callback;
- (id)initWithRequest:(NSURLRequest *)request delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag;

// Set timeout, default is 30s
- (void)setTimeOut:(NSInteger)seconds;

@end
