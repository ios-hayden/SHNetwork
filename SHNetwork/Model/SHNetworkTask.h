//
//  SHNetworkTask.h
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHNetworkDefinition.h"

@interface SHNetworkTask : NSObject

@property (nonatomic, copy, nonnull) NSString *url;
@property (nonatomic, copy, nullable) id params;
@property (nonatomic, weak, nullable) id requester;
@property (nonatomic, strong, nullable) Class responseClass;
@property (nonatomic, assign) SHRequestSerializer requestSerializer;
@property (nonatomic, copy, nullable) SHNetworkSuccess successBlock;
@property (nonatomic, copy, nullable) SHNetworkFailure failureBlock;
@property (nonatomic, copy, nullable) NSDictionary *additionalHeaders;

@end

@interface SHRequestTask : SHNetworkTask
@property (nonatomic, assign) SHNetworkMethod method;
@end

@class SHUploadPostData;

@interface SHUploadTask : SHNetworkTask
@property (nonatomic, strong, readonly, nullable) NSDictionary *postData;
@property (nonatomic, copy, nullable) SHNetworkProgress progressBlock;

- (nonnull instancetype)initWithPostData:(nonnull SHUploadPostData*)postData;
@end

@interface SHDownloadTask : SHNetworkTask
@property (nonatomic, assign) SHNetworkMethod method;
@property (nonatomic, copy, nullable) NSString *destination;
@property (nonatomic, copy, nullable) SHNetworkProgress progressBlock;
@end
