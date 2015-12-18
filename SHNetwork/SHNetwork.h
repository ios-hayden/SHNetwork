//
//  SHNetwork.h
//  SHNetwork
//
//  Created by Hayden on 15/11/25.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHNetworkDefinition.h"
#import "SHRequest.h"
#import "SHDownload.h"
#import "SHUpload.h"

@interface SHNetwork : NSObject

+ (SHNetworkMethod)methodWithString:(nonnull NSString*)method;

/**
 *  返回简单API请求器对象单例
 *
 *  @return 简单API请求器对象
 */
+ (nonnull SHRequest*)request;

/**
 *  返回下载器对象单例
 *
 *  @return 下载器单例
 */
+ (nonnull SHDownload*)download;

/**
 *  返回上传器对象单例
 *
 *  @return 上传器对象
 */
+ (nonnull SHUpload*)upload;
@end


