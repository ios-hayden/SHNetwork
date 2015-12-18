//
//  SHNetworkDefinition.h
//  SHNetworkDemo
//
//  Created by Hayden on 15/12/18.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#ifndef SHNetworkDefinition_h
#define SHNetworkDefinition_h

@class SHNetworkTask;

#pragma mark - Block
typedef void (^NextRequestMiddleware)( NSError * _Nullable error); // 下一个请求中间件调用的block定义
typedef void (^NextResponseMiddleware)(_Nullable id response,  NSError * _Nullable  error); // 下一个响应中间件的block定义
typedef void (^SHNetworkSuccess)(NSURLResponse * _Nonnull response, _Nullable id responseObject); // 请求成功回调block定义
typedef void (^SHNetworkFailure)(NSURLResponse * _Nullable response, NSError * _Nullable error); // 请求失败回调block定义
typedef void (^SHNetworkProgress)(double progress); // 上传/下载进度回调block定义

#pragma mark - Enum
typedef NS_ENUM(NSInteger, SHRequestSerializer) {
    SHRequestHTTPSerializer = 0,
    SHRequestJSONSerializer,
    SHRequestPropertyListSerializer
};

typedef NS_OPTIONS(NSInteger, SHResponseSerializer) {
    SHResponseHTTPSerializer = 1,
    SHResponsePListSerializer = 1 << 1,
    SHResponseXMLParserSerializer = 1 << 2,
    SHResponseImageSerializer = 1 << 3,
    SHResponseJSONSerializer = 1 << 4
};

/**
 *  网络请求方法枚举
 */
typedef NS_ENUM(NSInteger, SHNetworkMethod) {
    /**
     *  GET
     */
    SHNetworkGet = 0,
    /**
     *  POST
     */
    SHNetworkPost,
    SHNetworkHead,
    SHNetworkDelete,
    SHNetworkPut,
    SHNetworkPatch
};

#pragma mark - Protocol
/**
 *  网络请求中间件协议
 */
@protocol SHRequestMiddlewareProtocol <NSObject>

@required
/**
 *  网络请求中间件处理方法
 *
 *  @param task 网络请求任务
 *  @param next 下一个网络请求中间件执行Block，实现该方法需要在方法中合适的时机执行该block，否则网络请求会被拦截（如果你想这么做）
 */
- (void)handleRequestTask:(nonnull SHNetworkTask*)task next:(nonnull NextRequestMiddleware)next;

@end

/**
 *  网络响应中间件协议
 */
@protocol SHResponseMiddlewareProtocol <NSObject>

@required
/**
 *  网络响应中间件处理方法
 *
 *  @param task     网络请求任务
 *  @param response 网络响应数据
 *  @param error    网络响应错误
 *  @param next     下一个网络响应中间件执行Block，实现该方法需要在方法中合适的时机执行该block，否则网络响应会被拦截（如果你想这么做）
 */
- (void)handleResponseTask:(nonnull SHNetworkTask*)task response:(nonnull NSURLResponse*)response responseObject:(nullable id)responseObject error:(nullable NSError*)error next:(nonnull NextResponseMiddleware)next;

@end

/**
 *  网络请求配置协议
 */
@protocol SHNetworkConfigurationProtocol <NSObject>
@optional
/**
 *  返回响应超时时间（秒）
 *
 *  @return 响应超时时间（秒）
 */
- (NSTimeInterval)timeout;

/**
 *  返回额外的Header信息
 *
 *  @return 额外的Header信息
 */
- (nonnull NSDictionary*)additionalHeaders;

/**
 *  返回可接受的Content-Type集合
 *
 *  @return 可接受的Content-Type集合
 */
- (nonnull NSSet*)acceptableContentTypes;

/**
 *  返回网络请求缓存策略
 *
 *  @return 网络请求缓存策略，见NSURLRequestCachePolicy
 */
- (NSURLRequestCachePolicy)requestCachePolicy;

/**
 *  返回是否可以设置Cookie
 *
 *  @return 是否可以设置Cookie
 */
- (BOOL)shouldSetCookies;

/**
 *  返回Cookie接收策略
 *
 *  @return Cookie接收策略
 */
- (NSHTTPCookieAcceptPolicy)cookieAcceptPolicy;

/**
 *  返回CookieStorage
 *
 *  @return CookieStorage
 */
- (nonnull NSHTTPCookieStorage*)cookieStorage;

/**
 *  返回URLCache
 *
 *  @return URLCache
 */
- (nullable NSURLCache*)URLCache;

/**
 *  返回网络响应解析器数组，网络响应结果的解析将按照该数组顺序进行解析，如果无法解析则尝试下一个解析器进行解析
 *
 *  @return 网络解析器数组
 */
- (SHResponseSerializer)responseSerializer;

/**
 *  返回网络请求中间件数组，网络请求时将按该数组中中间件的顺序依次执行
 *
 *  @return 网络请求中间件数组
 */
- (nullable NSArray<id<SHRequestMiddlewareProtocol>>*)requestMiddlewares;

/**
 *  返回网络响应中间件数组，网络响应后将按该数组中中间件的顺序依次执行
 *
 *  @return 网络响应中间件数组
 */
- (nullable NSArray<id<SHResponseMiddlewareProtocol>>*)responseMiddlewares;
@end

#endif /* SHNetworkDefinition_h */
