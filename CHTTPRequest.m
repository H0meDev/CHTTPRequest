//
//  CHTTPRequest.m
//  NetworkSDK
//
//  Created by Cailiang on 14/12/26.
//  Copyright (c) 2014年 Cailiang. All rights reserved.
//

#import "CHTTPOperation.h"

@interface CHTTPRequest ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

static CHTTPRequest *sharedManager = nil;

@implementation CHTTPRequest

#pragma mark - Singleton

+ (CHTTPRequest *)sharedManager
{
    @synchronized (self)
    {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized (self) {
        if (sharedManager == nil) {
            sharedManager = [super allocWithZone:zone];
            return sharedManager;
        }
    }
    return nil;
}

- (id)init
{
    @synchronized(self) {
        self = [super init];
        return self;
    }
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

#pragma mark - Properties

- (NSOperationQueue *)operationQueue
{
    if (_operationQueue) {
        return _operationQueue;
    }
    
    _operationQueue = [[NSOperationQueue alloc]init];
    _operationQueue.maxConcurrentOperationCount = 30;
    
    return _operationQueue;
}

#pragma mark - Request

+ (void)requestPOST:(NSString *)urlString param:(NSDictionary *)param callback:(RequestCallback)callback
{
    // POST
    [[CHTTPRequest sharedManager] requestWithMethod:@"POST" url:urlString param:param callback:callback];
}

+ (void)requestGET:(NSString *)urlString param:(NSDictionary *)param callback:(RequestCallback)callback
{
    // GET
    [[CHTTPRequest sharedManager] requestWithMethod:@"GET" url:urlString param:param  callback:callback];
}

+ (void)requestPUT:(NSString *)urlString param:(NSDictionary *)param callback:(RequestCallback)callback
{
    // PUT
    [[CHTTPRequest sharedManager] requestWithMethod:@"PUT" url:urlString param:param  callback:callback];
}

+ (void)requestPOST:(NSString *)urlString param:(NSDictionary *)param delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag
{
    // POST
    [[CHTTPRequest sharedManager] requestWithMethod:@"POST" url:urlString param:param delegate:delegate tag:tag];
}

+ (void)requestGET:(NSString *)urlString param:(NSDictionary *)param delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag
{
    // GET
    [[CHTTPRequest sharedManager] requestWithMethod:@"GET" url:urlString param:param delegate:delegate tag:tag];
}

+ (void)requestPUT:(NSString *)urlString param:(NSDictionary *)param delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag
{
    // PUT
    [[CHTTPRequest sharedManager] requestWithMethod:@"PUT" url:urlString param:param delegate:delegate tag:tag];
}

- (void)requestWithMethod:(NSString *)method url:(NSString *)url param:(NSDictionary *)param callback:(RequestCallback)callback
{
    NSString *jsonString = @"";
    for (NSString *key in param) {
        NSString *value = param[key];
        jsonString = [jsonString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,value]];
    }
    
    if (jsonString.length > 0) {
        jsonString = [jsonString substringToIndex:jsonString.length - 1];
    }
    
    // Request
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    mutableRequest.HTTPMethod = method;
    mutableRequest.HTTPBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Add to operation queue
    CHTTPOperation *operation = [[CHTTPOperation alloc]initWithRequest:mutableRequest callback:callback];
    [operation setTimeOut:20];
    [self.operationQueue addOperation:operation];
}

- (void)requestWithMethod:(NSString *)method url:(NSString *)url param:(NSDictionary *)param delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag
{
    NSString *jsonString = @"";
    for (NSString *key in param) {
        NSString *value = param[key];
        jsonString = [jsonString stringByAppendingString:[NSString stringWithFormat:@"%@=%@&",key,value]];
    }
    
    if (jsonString.length > 0) {
        jsonString = [jsonString substringToIndex:jsonString.length - 1];
    }
    
    // Request
    NSMutableURLRequest *mutableRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    mutableRequest.HTTPMethod = method;
    mutableRequest.HTTPBody = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Add to operation queue
    CHTTPOperation *operation = [[CHTTPOperation alloc]initWithRequest:mutableRequest delegate:delegate tag:tag];
    [operation setTimeOut:20];
    [self.operationQueue addOperation:operation];
}

@end
