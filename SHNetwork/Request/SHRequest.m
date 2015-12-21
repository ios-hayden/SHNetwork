//
//  SHRequest.m
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHRequest.h"
#import <AFNetworking/AFNetworking.h>

static SHRequest *__instance = nil;

@interface SHBaseRequest (Protected)
@property (nonatomic, strong, nullable) AFHTTPSessionManager *manager;
@property (nonatomic, strong, nonnull) NSMapTable *taskSessionMap;

- (void)nextRequestMiddleware:(SHNetworkTask*)task next:(NSInteger)next error:(NSError*)error;
- (void)nextResponseMiddleware:(SHNetworkTask*)task response:(NSURLResponse*)response responseObject:(id)responseObject error:(NSError*)error next:(NSInteger)next;
- (void)removeTask:(SHNetworkTask*)task;
- (id<AFURLRequestSerialization>)requestSerializerWithOption:(SHRequestSerializer)serializer;
@end

@implementation SHRequest
+ (nonnull SHRequest*)instance
{
    if (!__instance) {
        __instance = [[SHRequest alloc]init];
    }
    return __instance;
}

#pragma mark - Public Methods - Request
- (void)requester:(nonnull id)requester post:(nonnull NSString*)url params:(nullable id)params success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure
{
    [self requester:requester url:url params:params method:SHNetworkPost success:success failure:failure];
}

- (void)requester:(nonnull id)requester get:(nonnull NSString*)url params:(nullable id)params success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure
{
    [self requester:requester url:url params:params method:SHNetworkGet success:success failure:failure];
}

- (void)requester:(nonnull id)requester url:(nonnull NSString*)url params:(nullable id)params method:(SHNetworkMethod)method success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure
{
    [self requester:requester url:url params:params method:method responseClass:nil success:success failure:failure];
}

- (void)requester:(nonnull id)requester post:(nonnull NSString*)url params:(nullable id)params responseClass:(nullable Class)class  success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure
{
    [self requester:requester url:url params:params method:SHNetworkPost responseClass:class success:success failure:failure];
}

- (void)requester:(nonnull id)requester get:(nonnull NSString*)url params:(nullable id)params responseClass:(nullable Class)class success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure
{
    [self requester:requester url:url params:params method:SHNetworkGet responseClass:class success:success failure:failure];
}

- (void)requester:(nonnull id)requester url:(nonnull NSString*)url params:(nullable id)params method:(SHNetworkMethod)method responseClass:(nullable Class)class success:(nullable SHNetworkSuccess)success failure:(nullable SHNetworkFailure)failure
{
    SHRequestTask *task = [[SHRequestTask alloc]init];
    task.method = method;
    task.url = url;
    task.params = params;
    task.successBlock = success;
    task.failureBlock = failure;
    task.requester = requester;
    task.responseClass = class;
    [self nextRequestMiddleware:task next:0 error:nil];
}

- (void)requestWithTask:(SHRequestTask*)task
{
    [self nextRequestMiddleware:task next:0 error:nil];
}

- (void)submitRequest:(SHNetworkTask*)task
{
    SHRequestTask *strongTask = (SHRequestTask*)task;
    __strong id requestor = strongTask.requester;
    if (requestor == nil) {
        [self removeTask:strongTask];
        return;
    }
    
    AFHTTPSessionManager *manager = self.manager;
    manager.requestSerializer = [self requestSerializerWithOption:strongTask.requestSerializer];
    strongTask.additionalHeaders = manager.session.configuration.HTTPAdditionalHeaders;
    NSURLSessionDataTask *sessionTask;
    switch (strongTask.method) {
        case SHNetworkPost:
        {
            sessionTask = [manager POST:strongTask.url parameters:strongTask.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:responseObject error:nil next:0];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:nil error:error next:0];
            }];
        }
            break;
            
        case SHNetworkGet:
        {
            sessionTask = [manager GET:strongTask.url parameters:strongTask.params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:responseObject error:nil next:0];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:nil error:error next:0];
            }];
        }
            break;
            
        case SHNetworkDelete:
        {
            sessionTask = [manager DELETE:strongTask.url parameters:strongTask.params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:responseObject error:nil next:0];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:nil error:error next:0];
            }];
        }
            break;
            
        case SHNetworkHead:
        {
            sessionTask = [manager HEAD:strongTask.url parameters:strongTask.params success:^(NSURLSessionDataTask * _Nonnull task) {
                id headers;
                if ([task.response isKindOfClass:[NSHTTPURLResponse class]]) {
                    headers = ((NSHTTPURLResponse*)task.response).allHeaderFields;
                }
                [self nextResponseMiddleware:strongTask response:task.response responseObject:headers error:nil next:0];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:nil error:error next:0];
            }];
        }
            break;
            
        case SHNetworkPut:
        {
            sessionTask = [manager PUT:strongTask.url parameters:strongTask.params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:responseObject error:nil next:0];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:nil error:error next:0];
            }];
        }
            break;
            
        case SHNetworkPatch:
        {
            sessionTask = [manager PATCH:strongTask.url parameters:strongTask.params success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:responseObject error:nil next:0];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                [self nextResponseMiddleware:strongTask response:task.response responseObject:nil error:error next:0];
            }];
        }
            break;
            
        default:
            // Do nothing
            return;
            break;
    }
    
    @synchronized(self.taskSessionMap) {
        [self.taskSessionMap setObject:sessionTask forKey:strongTask];
    }
}
@end