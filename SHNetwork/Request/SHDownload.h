//
//  SHDownload.h
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHBaseRequest.h"

@interface SHDownload : SHBaseRequest
/**
 *  返回SHDownload单例
 *
 *  @return SHDownload单例
 */
+ (nonnull SHDownload*)instance;

/**
 *  以GET方式发起一个下载任务，文件下载后将保存到Cache目录下并生成随机文件名
 *
 *  @param requester 下载任务发起对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param progress  下载进度回调，double
 *  @param success   成功的回调，返回文件保存路径
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester get:(nonnull NSString*)url params:(nullable id)params progress:(nullable SHNetworkProgress)progress success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  以GET方式发起一个下载任务
 *
 *  @param requester   下载任务发起对象
 *  @param url         网络链接
 *  @param params      参数
 *  @param destination 下载文件保存绝对路径
 *  @param progress    下载进度回调，double
 *  @param success     成功的回调，返回文件保存路径
 *  @param failure     失败的回调
 */
- (void)requester:(nonnull id)requester get:(nonnull NSString *)url params:(nullable id)params destination:(nonnull NSString*)destination progress:(nullable SHNetworkProgress)progress success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  以POST方式发起一个下载任务，文件下载后将保存到Cache目录下并生成随机文件名
 *
 *  @param requester 下载任务发起对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param progress  下载进度回调，double
 *  @param success   成功的回调，返回文件保存路径
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester post:(nonnull NSString*)url params:(nullable id)params progress:(nullable SHNetworkProgress)progress success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  以POST方式发起一个下载任务
 *
 *  @param requester   下载任务发起对象
 *  @param url         网络链接
 *  @param params      参数
 *  @param destination 下载文件保存绝对路径
 *  @param progress    下载进度回调，double
 *  @param success     成功的回调，返回文件保存路径
 *  @param failure     失败的回调
 */
- (void)requester:(nonnull id)requester post:(nonnull NSString*)url params:(nullable id)params destination:(nonnull NSString*)destination progress:(nullable SHNetworkProgress)progress success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

- (void)requestWithTask:(nonnull SHDownloadTask*)task;
@end
