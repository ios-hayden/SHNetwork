//
//  SHUpload.m
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHUpload.h"
#import <AFNetworking/AFNetworking.h>

static SHUpload *__instance;
extern dispatch_queue_t base_network_progress_queue();

@interface SHBaseRequest (Protected)

@property (nonatomic, strong, nullable) AFHTTPSessionManager *manager;
@property (nonatomic, strong, nonnull) NSMapTable *taskSessionMap;

- (void)nextRequestMiddleware:(SHNetworkTask*)task next:(NSInteger)next error:(NSError*)error;
- (void)nextResponseMiddleware:(SHNetworkTask*)task response:(NSURLResponse*)response responseObject:(id)responseObject error:(NSError*)error next:(NSInteger)next;
- (void)removeTask:(SHNetworkTask*)task;
- (id<AFURLRequestSerialization>)requestSerializerWithOption:(SHRequestSerializer)serializer;
@end

@interface SHUpload ()
@property (nonatomic, strong, nonnull) NSMapTable *progressTaskMap;
@end

@implementation SHUpload
- (instancetype)init
{
    self = [super init];
    if (self) {
        _progressTaskMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsWeakMemory valueOptions:NSPointerFunctionsWeakMemory];
    }
    return self;
}


+ (nonnull SHUpload*)instance
{
    if (!__instance) {
        __instance = [[SHUpload alloc]init];
    }
    return __instance;
}

#pragma mark - Public Methods - Request
- (void)requester:(id)requester uploadUrl:(NSString*)url params:(id)params data:(NSData*)data key:(NSString*)key mineType:(SHUploadFileMineType)mineType progress:(SHNetworkProgress)progress success:(SHNetworkSuccess)success failure:(SHNetworkFailure)failure
{
    SHUploadPostData *postData = [[SHUploadPostData alloc]init];
    [postData setData:data withMineType:mineType forKey:key];
    [self requester:url uploadUrl:url params:params postData:postData progress:progress success:success failure:failure];
}

- (void)requester:(id)requester uploadUrl:(NSString*)url params:(id)params data:(NSData*)data key:(NSString*)key stringMineType:(NSString*)mineType progress:(SHNetworkProgress)progress success:(SHNetworkSuccess)success failure:(SHNetworkFailure)failure
{
    SHUploadPostData *postData = [[SHUploadPostData alloc]init];
    [postData setData:data withStringMineType:mineType forKey:key];
    [self requester:requester uploadUrl:url params:params postData:postData progress:progress success:success failure:failure];
}

- (void)requester:(id)requester uploadUrl:(NSString*)url params:(id)params postData:(SHUploadPostData*)postData progress:(SHNetworkProgress)progress success:(SHNetworkSuccess)success failure:(SHNetworkFailure)failure
{
    if ([postData.postData allKeys].count==0) {
        return;
    }
    SHUploadTask *task = [[SHUploadTask alloc]initWithPostData:postData];
    task.requester = requester;
    task.url = url;
    task.params = params;
    task.progressBlock = progress;
    task.successBlock = success;
    task.failureBlock = failure;
    [self nextRequestMiddleware:task next:0 error:nil];
}

- (void)requestWithTask:(SHUploadTask*)task
{
    [self nextRequestMiddleware:task next:0 error:nil];
}

#pragma mark - Private Methods - Submit Request
- (void)submitRequest:(SHNetworkTask*)task
{
    SHUploadTask *strongTask = (SHUploadTask*)task;
    __weak SHUploadTask *weakTask = (SHUploadTask*)task;
    __strong id requestor = task.requester;
    if (requestor == nil) {
        [self removeTask:task];
        return;
    }
    
    AFHTTPSessionManager *manager = self.manager;
    manager.requestSerializer = [self requestSerializerWithOption:strongTask.requestSerializer];
    task.additionalHeaders = manager.session.configuration.HTTPAdditionalHeaders;
    AFHTTPRequestSerializer *serializer = manager.requestSerializer;
    NSError *error;
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST" URLString:task.url parameters:strongTask.params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        for (NSString *key in [strongTask.postData allKeys]) {
            NSDictionary *dicItem = [strongTask.postData objectForKey:key];
            NSData *data = [dicItem objectForKey:@"data"];
            NSString *fileName = [dicItem objectForKey:@"fileName"];
            fileName = fileName.length ? fileName : @"undefined";
            NSString *mineType = [dicItem objectForKey:@"mineType"];
            [formData appendPartWithFileData:data name:key fileName:fileName mimeType:mineType];
        }
    } error:&error];
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            task.failureBlock(nil, error);
            [self removeTask:task];
        });
        return;
    }
    
    NSURLSessionDataTask *sessionTask = [manager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        if (weakTask.progressBlock) {
            weakTask.progressBlock(uploadProgress.fractionCompleted);
        }
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self nextResponseMiddleware:strongTask response:response responseObject:responseObject error:error next:0];
    }];
    
    @synchronized(self.taskSessionMap) {
        [self.taskSessionMap setObject:sessionTask forKey:strongTask];
    }
    
    [sessionTask resume];
}
@end
