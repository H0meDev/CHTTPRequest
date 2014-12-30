//
//  CHTTPOperation.m
//  NetworkSDK
//
//  Created by Cailiang on 14-9-16.
//  Copyright (c) 2014年 Cailiang. All rights reserved.
//

#import "CHTTPOperation.h"
#import "CTimerBooster.h"

@interface CHTTPOperation () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
{
    time_t start_time;
    __block RequestCallback _callback;
    __weak id<CHTTPRequestDelegate> _delegate;
    int _tag;
    NSInteger _timeout;
}

// Connection
@property (nonatomic, strong) NSURLConnection *connection;

// Response
@property (nonatomic, readonly) NSHTTPURLResponse *response;

// Received data
@property (nonatomic, readonly) NSMutableData *receivedData;

// Response object
@property (nonatomic, readonly, retain) id responseObject;

@end

@implementation CHTTPOperation

#pragma mark - Life Circle

- (id)initWithRequest:(NSURLRequest *)request callback:(RequestCallback)callback
{
    self = [super init];
    if (self) {
        self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
#pragma clang diagnostic ignored "-Wgnu"
        _callback = [callback copy];
        
        // Default is 30
        [self setTimeOut:30];
    }
    return self;
}

- (id)initWithRequest:(NSURLRequest *)request delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag
{
    self = [super init];
    if (self) {
        self.connection = [[NSURLConnection alloc]initWithRequest:request delegate:self startImmediately:NO];
        _delegate = delegate;
        _tag = tag;
        
        // Default is 30
        [self setTimeOut:30];
    }
    return self;
}

- (void)main
{
    NSLog(@"CHTTP REQUEST START");
    
    // Start time
    start_time = clock();
    
    // Timeout setting
    [CTimerBooster addTarget:self sel:@selector(timeOutAction) time:_timeout];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];
}

- (void)dealloc
{
    _receivedData = nil;
    _response = nil;
    _delegate = nil;
    _callback = NULL;
    
    NSLog(@"CHTTPRequestOperation dealloc");
}

#pragma mark - Self Methods

- (void)setTimeOut:(NSInteger)seconds
{
    if (seconds > 0) {
        _timeout = seconds * 1000;
    }
    
    [CTimerBooster start];
}

- (void)timeOutAction
{
    if (self.connection) {
        // Time out !
        NSURLRequest *request = self.connection.originalRequest;
        NSLog(@"\nCHTTP REQUEST RESULT\n*********************\nSTATUS: TIMEOUT\nURL: %@\nTIME: %@ms\n*********************",request.URL.absoluteString,[NSNumber numberWithInteger:_timeout]);
        
        [self.connection cancel];
        self.connection = nil;
        
        if (_callback) {
            _callback(CHTTPCodeRequestTimeout, nil);
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(requestCallback:status:data:)]) {
                [_delegate requestCallback:_tag status:CHTTPCodeRequestTimeout data:nil];
            }
        }
    }
}

#pragma mark - NSURLConnectionDelegate & NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"CHTTP RECEIVED RESPONSE:\n%@",response.description);
    _response = (NSHTTPURLResponse *)response;
    
    // Cancel timeout
    [CTimerBooster removeTarget:self sel:@selector(timeOutAction)];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (_receivedData == nil) {
        _receivedData = [[NSMutableData alloc]init];
    }
    
    [_receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    
    NSURLRequest *request = [connection originalRequest];
    clock_t end_time = clock();
    CGFloat usedTime = (CGFloat)(end_time - start_time)/CLOCKS_PER_SEC;
    NSString *status = @"OK";
    
    @try
    {
        NSStringEncoding stringEncoding = NSUTF8StringEncoding;
        if (_response.textEncodingName) {
            if ([_response.textEncodingName isEqualToString:@"gb2312"]) {
                stringEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            } else {
                CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)_response.textEncodingName);
                if (encoding != kCFStringEncodingInvalidId) {
                    stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
                }
            }
        }
        
        // Parse data
        NSString *responseString = [[NSString alloc] initWithData:_receivedData encoding:stringEncoding];
        
        _responseObject = nil;
        NSError *error = nil;
        
        if (responseString && ![responseString isEqualToString:@" "]) {
            // To JSON
            NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
            if (data) {
                if ([data length] > 0) {
                    _responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                }
            } else {
                NSLog(@"Current data is not valid");
            }
        }
        
        if (error && !_responseObject) {
            NSLog(@"Current data is not JSON");
            _responseObject = responseString;
        }
        
        responseString = nil;
    }
    @catch (NSException *exception)
    {
        status = @"Parse exception";
    }
    @finally
    {
        NSLog(@"\nCHTTP REQUEST RESULT\n*********************\nSTATUS: %@\nURL: %@\nDATA:\n%@\nTIME: %fs\n*********************",status,request.URL.absoluteString,_responseObject,usedTime);
        
        if (_callback) {
            _callback(_response.statusCode, _responseObject);
        } else {
            if (_delegate && [_delegate respondsToSelector:@selector(requestCallback:status:data:)]) {
                [_delegate requestCallback:_tag status:_response.statusCode data:_responseObject];
            }
        }
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    self.connection = nil;
    
    clock_t end_time = clock();
    CGFloat usedTime = (CGFloat)(end_time - start_time)/CLOCKS_PER_SEC;
    
    NSURLRequest *request = [connection originalRequest];
    NSLog(@"\nCHTTP REQUEST RESULT\n*********************\nSTATUS: ERROR\nURL: %@\nDESCRIPTION:\n%@\nTIME: %fs\n*********************",request.URL.absoluteString,error.description,usedTime);
    
    if (_callback) {
        _callback(_response.statusCode, nil);
    } else {
        if (_delegate && [_delegate respondsToSelector:@selector(requestCallback:status:data:)]) {
            [_delegate requestCallback:_tag status:_response.statusCode data:nil];
        }
    }
    
    // Cancel timeout
    [CTimerBooster removeTarget:self sel:@selector(timeOutAction)];
}

#pragma mark - For HTTPS request

- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection *)connection
{
    return NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        [[challenge sender]useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]forAuthenticationChallenge:challenge];
        [[challenge sender]continueWithoutCredentialForAuthenticationChallenge:challenge];
    }
}

@end
