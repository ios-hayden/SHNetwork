//
//  SHBaseRequest.h
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHNetworkDefinition.h"
#import "SHNetworkTask.h"

@interface SHBaseRequest : NSObject
/**
 *  使用配置并刷新配置
 *
 *  @param configuration 需要使用的配置对象，该对象需实现SHNetworkConfigurationProtocol
 */
- (void)useConfiguration:(nonnull id<SHNetworkConfigurationProtocol>)configuration;

/**
 *  刷新配置，将从当前配置对象重新读取配置信息并应用
 */
- (void)refreshConfiguration;

/**
 *  冻结任务，被冻结的任务将停止被添加到等待队列
 *
 *  @param task 需要冻结的任务
 */
- (void)freezeTask:(nonnull SHNetworkTask*)task;

/**
 *  重试任务，该任务将重新添加到请求队列，如果该任务在等待队列，则将该任务从等待队列移除
 *
 *  @param task 需要重试的任务
 */
- (void)retryTask:(nonnull SHNetworkTask*)task;

/**
 *  重试所有被冻结的任务
 */
- (void)retryAllFrozenTasks;

/**
 *  移除所有被冻结的任务
 */
- (void)removeAllFrozenTasks;

/**
 *  取消任务，被取消的任务将停止网络请求，并且不会调用该任务成功或失败的回调
 *
 *  @param task <#task description#>
 */
- (void)cancelTask:(nonnull SHNetworkTask*)task;

/**
 *  取消网络请求者（网络请求创建对象）所提交的任务
 *
 *  @param requester 网络请求任务的创建对象
 */
- (void)cancelAllTasksByRequester:(nonnull id)requester;

/**
 *  取消当前所有任务
 */
- (void)cancelAllTasks;
@end
