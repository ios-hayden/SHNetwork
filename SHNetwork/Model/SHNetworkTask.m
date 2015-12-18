//
//  SHNetworkTask.m
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHNetworkTask.h"
#import "SHUploadPostData.h"

@implementation SHNetworkTask
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.requestSerializer = SHRequestHTTPSerializer;
    }
    return self;
}
@end


@implementation SHRequestTask

@end

@implementation SHUploadTask
- (instancetype)initWithPostData:(SHUploadPostData*)postData
{
    self = [super init];
    if (self) {
        _postData = postData.postData;
    }
    return self;
}
@end

@implementation SHDownloadTask

@end