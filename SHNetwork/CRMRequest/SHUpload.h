//
//  SHUpload.h
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHBaseRequest.h"
#import "SHUploadPostData.h"

@interface SHUpload : SHBaseRequest
/**
 *  返回SHUpload单例
 *
 *  @return SHUpload单例
 */
+ (nonnull SHUpload*)instance;

/**
 *  发起一个上传任务
 *
 *  @param requester 上传任务发起对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param data      上传数据
 *  @param key       上传数据对应的参数名
 *  @param mineType  文件的MineTYpe，枚举
 *  @param progress  上传进度回调
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester uploadUrl:(nonnull NSString*)url params:(nullable id)params data:(nonnull NSData*)data key:(nonnull NSString*)key mineType:(SHUploadFileMineType)mineType progress:(nullable SHNetworkProgress)progress success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  发起一个上传任务
 *
 *  @param requester 上传任务发起对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param data      上传数据
 *  @param key       上传数据对应的参数名
 *  @param mineType  文件的MineTYpe，字符串
 *  @param progress  上传进度回调
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester uploadUrl:(nonnull NSString*)url params:(nullable id)params data:(nonnull NSData*)data key:(nonnull NSString*)key stringMineType:(nullable NSString*)mineType progress:(nullable SHNetworkProgress)progress success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

/**
 *  发起一个上传任务
 *
 *  @param requester 上传任务发起对象
 *  @param url       网络链接
 *  @param params    参数
 *  @param postData  上传数据封装对象，见SHUploadPostData
 *  @param progress  上传进度回调
 *  @param success   成功的回调
 *  @param failure   失败的回调
 */
- (void)requester:(nonnull id)requester uploadUrl:(nonnull NSString*)url params:(nullable id)params postData:(nonnull SHUploadPostData*)postData progress:(nullable SHNetworkProgress)progress success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure;

- (void)requestWithTask:(nonnull SHUploadTask*)task;
@end


