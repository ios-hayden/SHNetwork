//
//  SHRequest.h
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHBaseRequest.h"

@interface SHRequest : SHBaseRequest
/**
 *  返回SHRequest单例
 *
 *  @return SHRequest单例
 */
+ (nonnull SHRequest*)instance;


/**
 *  以POST方式发起网络请求
 *
 *  @param requester 网络请求对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester post:(nonnull NSString*)url params:(nullable id)params success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  以GET方式发起网络请求
 *
 *  @param requester 网络请求对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester get:(nonnull NSString*)url params:(nullable id)params success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  发起网络请求
 *
 *  @param requester 网络请求对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param method    网络请求方法，见SHNetworkMethod
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester url:(nonnull NSString*)url params:(nullable id)params method:(SHNetworkMethod)method success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  以POST方式发起网络请求
 *
 *  @param requester 网络请求对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param class     响应结果转换对象，如果为nil则返回NSDictionary，如果不为nil,需要在在响应中间件中按此类进行转换
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester post:(nonnull NSString*)url params:(nullable id)params responseClass:(nullable Class)class  success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  以GET方式发起网络请求
 *
 *  @param requester 网络请求对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param class     响应结果转换对象，如果为nil则返回NSDictionary，如果不为nil,需要在在响应中间件中按此类进行转换
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester get:(nonnull NSString*)url params:(nullable id)params responseClass:(nullable Class)class success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;


/**
 *  发起网络请求
 *
 *  @param requester 网络请求对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param method    网络请求方法，见SHNetworkMethod
 *  @param class     响应结果转换对象，如果为nil则返回NSDictionary，如果不为nil,需要在在响应中间件中按此类进行转换
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester url:(nonnull NSString*)url params:(nullable id)params method:(SHNetworkMethod)method responseClass:(nullable Class)class success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

- (void)requestWithTask:(nonnull SHRequestTask*)task;
@end
