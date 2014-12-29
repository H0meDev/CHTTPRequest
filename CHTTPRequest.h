//
//  CHTTPRequest.h
//  NetworkSDK
//
//  Created by Cailiang on 14/12/26.
//  Copyright (c) 2014年 Cailiang. All rights reserved.
//

#import <Foundation/Foundation.h>

// References http://httpstatus.es/
typedef NS_ENUM(NSInteger, CHTTPCode)
{
    CHTTPCodeOffline                          = 0,
    
    CHTTPCodeOK                               = 200,
    CHTTPCodeCreated                          = 201,
    CHTTPCodeAccepted                         = 202,
    CHTTPCodeNonAuthoritativeInfo             = 203,
    CHTTPCodeNoContent                        = 204,
    CHTTPCodeResetContent                     = 205,
    CHTTPCodePartialContent                   = 206,
    
    CHTTPCodeMultipleChoices                  = 300,
    CHTTPCodeMovedPermanently                 = 301,
    CHTTPCodeFound                            = 302,
    CHTTPCodeSeeOther                         = 303,
    CHTTPCodeNotModified                      = 304,
    CHTTPCodeUseProxy                         = 305,
    CHTTPCodeTemporaryRedirect                = 307,
    
    CHTTPCodeBadRequest                       = 400,
    CHTTPCodeUnauthorized                     = 401,
    CHTTPCodeForbidden                        = 403,
    CHTTPCodeNotFound                         = 404,
    CHTTPCodeMethodNotAllowed                 = 405,
    CHTTPCodeMethodNotAcceptable              = 406,
    CHTTPCodeProxyAuthenticationRequired      = 407,
    CHTTPCodeRequestTimeout                   = 408,
    CHTTPCodeConflict                         = 409,
    CHTTPCodeGone                             = 410,
    CHTTPCodeLengthRequired                   = 411,
    
    CHTTPCodeInternalServerError              = 500,
    CHTTPCodeNotImplemented                   = 501,
    CHTTPCodeBadGateway                       = 502,
    CHTTPCodeServiceUnavailable               = 503,
    CHTTPCodeGatewayTimeout                   = 504,
    CHTTPCodeHttpVersionNotSupported          = 505,
};

@protocol CHTTPRequestDelegate <NSObject>

- (void)requestCallback:(int)tag status:(CHTTPCode)status data:(id)data;

@end

typedef void (^RequestCallback)(CHTTPCode status, id data);


@interface CHTTPRequest : NSObject

// Block
+ (void)requestPOST:(NSString *)urlString param:(NSDictionary *)param callback:(RequestCallback)callback;
+ (void)requestGET:(NSString *)urlString param:(NSDictionary *)param callback:(RequestCallback)callback;
+ (void)requestPUT:(NSString *)urlString param:(NSDictionary *)param callback:(RequestCallback)callback;

// Delegate
+ (void)requestPOST:(NSString *)urlString param:(NSDictionary *)param delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag;
+ (void)requestGET:(NSString *)urlString param:(NSDictionary *)param delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag;
+ (void)requestPUT:(NSString *)urlString param:(NSDictionary *)param delegate:(id<CHTTPRequestDelegate>)delegate tag:(int)tag;

@end
