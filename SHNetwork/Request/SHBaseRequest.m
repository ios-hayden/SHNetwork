//
//  SHBaseRequest.m
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHBaseRequest.h"
#import <AFNetworking/AFNetworking.h>

dispatch_queue_t base_network_manager_queue() {
    static dispatch_queue_t base_network_manager_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base_network_manager_queue = dispatch_queue_create("com.dianping.SHnetwork.queue", DISPATCH_QUEUE_SERIAL);
    });
    return base_network_manager_queue;
}

dispatch_queue_t base_network_request_middleware_queue() {
    static dispatch_queue_t base_network_request_middleware_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base_network_request_middleware_queue = dispatch_queue_create("com.dianping.SHnetwork.request.middleware.queue", DISPATCH_QUEUE_SERIAL);
    });
    return base_network_request_middleware_queue;
}

dispatch_queue_t base_network_response_middleware_queue() {
    static dispatch_queue_t base_network_response_middleware_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base_network_response_middleware_queue = dispatch_queue_create("com.dianping.SHnetwork.response.middleware.queue", DISPATCH_QUEUE_SERIAL);
    });
    return base_network_response_middleware_queue;
}

dispatch_queue_t base_network_progress_queue() {
    static dispatch_queue_t base_network_progress_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        base_network_progress_queue = dispatch_queue_create("com.dianping.SHnetwork.middleware.progress.queue", DISPATCH_QUEUE_SERIAL);
    });
    return base_network_progress_queue;
}

@interface SHBaseRequest ()
@property (nonatomic, strong, nonnull) id<SHNetworkConfigurationProtocol> configuration;
@property (nonatomic, strong, nullable) AFHTTPSessionManager *manager;

// 映射
@property (nonatomic, strong, nonnull) NSMapTable *taskSessionMap;

// 数组
@property (nonatomic, strong, nullable) NSArray *requestMiddles;
@property (nonatomic, strong, nullable) NSArray *responseMiddles;
@property (nonatomic, strong, nullable) NSMutableArray *muArrayFrozen;
@property (nonatomic, strong, nonnull) NSMutableArray *muArrayManagers;

@property (nonatomic, strong, nonnull) AFHTTPRequestSerializer *httpReqSerializer;
@property (nonatomic, strong, nonnull) AFJSONRequestSerializer *jsonReqSerializer;
@property (nonatomic, strong, nonnull) AFPropertyListRequestSerializer *plistReqSerializer;
@end

@implementation SHBaseRequest
- (instancetype)init
{
    if (self.class == [SHBaseRequest class]) {
        NSAssert(NO, @"This class should not to be instantiated! It been designed as a abstract class");
        return nil;
    }else{
        self = [super init];
        if (self) {
            _taskSessionMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsStrongMemory valueOptions:NSPointerFunctionsStrongMemory];
            _muArrayManagers = [[NSMutableArray alloc]initWithCapacity:6];
        }
        return self;
    }
}

#pragma mark - Public Methods - Settings
- (void)useConfiguration:(nonnull id<SHNetworkConfigurationProtocol>)configuration
{
    _configuration = configuration;
    [self refreshConfiguration];
}

- (void)refreshConfiguration
{
    @synchronized(self.muArrayManagers) {
        if (self.muArrayManagers.count>1) {
            NSRange range = NSMakeRange(0, (self.muArrayManagers.count-1));
            NSArray *array = [[NSArray alloc]initWithArray:[self.muArrayManagers subarrayWithRange:range]];
            for (AFHTTPSessionManager *manager in array) {
                if (manager.operationQueue.operationCount == 0) {
                    [self.muArrayManagers removeObject:manager];
                }
            }
        }
        [self.muArrayManagers addObject:[self newSessionManager]];
    }
}

- (void)freezeTask:(SHNetworkTask*)task
{
    [self cancelTask:task];
    
    __strong id requestor = task.requester;
    @synchronized(self.muArrayFrozen) {
        if (requestor && ![self.muArrayFrozen containsObject:task]) {
            [self.muArrayFrozen addObject:task];
        }
    }
}

- (void)retryTask:(SHNetworkTask*)task
{
    [self cancelTask:task];
    
    @synchronized(self.muArrayFrozen) {
        if ([self.muArrayFrozen containsObject:task]) {
            [self.muArrayFrozen removeObject:task];
        }
    }
    
    __strong id requestor = task.requester;
    if (requestor) {
        [self nextRequestMiddleware:task next:0 error:nil];
    }
}

- (void)retryAllFrozenTasks
{
    @synchronized(self.muArrayFrozen) {
        NSArray *muArrayFrozenTask = [[NSArray alloc]initWithArray:self.muArrayFrozen];
        for (SHNetworkTask *task in muArrayFrozenTask) {
            [self retryTask:task];
        }
    }
}

- (void)removeAllFrozenTasks
{
    @synchronized(self.muArrayFrozen) {
        [self.muArrayFrozen removeAllObjects];
    }
}

- (void)cancelTask:(SHNetworkTask*)task
{
    @synchronized(self.taskSessionMap) {
        __strong NSURLSessionTask *sessionTask = [self.taskSessionMap objectForKey:task];
        [self removeTask:task];
        if (sessionTask && sessionTask.state != NSURLSessionTaskStateCompleted ) {
            [sessionTask cancel];
        }
    }
}

- (void)cancelAllTasksByRequester:(id)requester
{
    @synchronized(self.taskSessionMap) {
        for (SHNetworkTask *task in [self.taskSessionMap.keyEnumerator allObjects]) {
            if (task.requester == requester) {
                [self cancelTask:task];
            }
        }
    }
}

- (void)cancelAllTasks
{
    @synchronized(self.taskSessionMap) {
        for (SHNetworkTask *task in [self.taskSessionMap.keyEnumerator allObjects]) {
            [self cancelTask:task];
        }
    }
}

#pragma mark - Protected - Submit Request
- (void)submitRequest:(SHNetworkTask*)task
{
    
}

#pragma mark - Middleware Schedule
- (void)nextRequestMiddleware:(SHNetworkTask*)task next:(NSInteger)next error:(NSError*)error
{
    dispatch_async(base_network_manager_queue(), ^{
        __strong id requestor = task.requester;
        if (requestor == nil) {
            [self removeTask:task];
        }else if(error){
            if (task.failureBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                   task.failureBlock(nil, error);
                });
            }
            [self removeTask:task];
        }else if (next<self.requestMiddles.count) {
            __block NSInteger index = next + 1;
            NextRequestMiddleware block = ^(NSError *errorBlock){
                [self nextRequestMiddleware:task next:index error:errorBlock];
            };
            id<SHRequestMiddlewareProtocol> middleware = self.requestMiddles[next];
            dispatch_async(base_network_request_middleware_queue(), ^{
                [middleware handleRequestTask:task next:block];
            });
        }else{
            dispatch_async(base_network_manager_queue(), ^{
                [self submitRequest:task];
            });
        }
    });
}

- (void)nextResponseMiddleware:(SHNetworkTask*)task response:(NSURLResponse*)response responseObject:(id)responseObject error:(NSError*)error next:(NSInteger)next
{
    dispatch_async(base_network_manager_queue(), ^{
        
        @synchronized(self.taskSessionMap) {
            if ([self.taskSessionMap objectForKey:task] == nil) {
                return;
            }
        }
        
        __strong id requestor = task.requester;
        if (requestor == nil) {
            [self removeTask:task];
        }else if (next<self.responseMiddles.count) {
            __block NSInteger index = next + 1;
            NextResponseMiddleware block = ^(id responseBlock, NSError *errorBlock){
                [self nextResponseMiddleware:task response:response responseObject:responseBlock error:errorBlock next:index];
            };
            id<SHResponseMiddlewareProtocol> middleware = self.responseMiddles[next];
            dispatch_async(base_network_response_middleware_queue(), ^{
                [middleware handleResponseTask:task response:response responseObject:responseObject error:error next:block];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error && task.failureBlock) {
                    task.failureBlock(response, error);
                }else if (task.successBlock) {
                    task.successBlock(response, responseObject);
                }
            });
            [self removeTask:task];
        }
    });
}

#pragma mark - Private Methods
- (id<AFURLRequestSerialization>)requestSerializerWithOption:(SHRequestSerializer)serializer;
{
    switch (serializer) {
        case SHRequestJSONSerializer:
            return self.jsonReqSerializer;
            break;
        case SHRequestPropertyListSerializer:
            return self.plistReqSerializer;
            break;
        default:
            return self.httpReqSerializer;
            break;
    }
}

- (NSArray*)responseSerializer:(SHResponseSerializer)serializer
{
    NSMutableArray *muArray = [[NSMutableArray alloc]initWithCapacity:5];
    if ((serializer & SHResponseJSONSerializer) > 0) {
        [muArray addObject:[AFJSONResponseSerializer serializer]];
    }
    if ((serializer & SHResponseImageSerializer) > 0) {
        [muArray addObject:[AFImageResponseSerializer serializer]];
    }
    if ((serializer & SHResponseXMLParserSerializer) > 0) {
        [muArray addObject:[AFXMLParserResponseSerializer serializer]];
    }
    if ((serializer & SHResponsePListSerializer) > 0) {
        [muArray addObject:[AFPropertyListResponseSerializer serializer]];
    }
    if ((serializer & SHResponseHTTPSerializer) > 0) {
        [muArray addObject:[AFHTTPResponseSerializer serializer]];
    }
    
    if ([self.configuration respondsToSelector:@selector(acceptableContentTypes)]) {
        for (AFHTTPResponseSerializer *resSerializer in muArray) {
            resSerializer.acceptableContentTypes = [self.configuration acceptableContentTypes];
        }
    }
    
    return muArray;
}

- (void)removeTask:(SHNetworkTask*)task
{
    __strong SHNetworkTask *strongTask = task;
    if (strongTask==nil) {
        return;
    }
    @synchronized(self.taskSessionMap) {
        NSURLSessionTask *sessionTask = [self.taskSessionMap objectForKey:strongTask];
        [self.taskSessionMap removeObjectForKey:strongTask];
        if (sessionTask && sessionTask.state != NSURLSessionTaskStateCompleted) {
            [sessionTask cancel];
        }
    }
    @synchronized(self.muArrayFrozen) {
        if ([self.muArrayFrozen containsObject:strongTask]) {
            [self.muArrayFrozen removeObject:strongTask];
        }
    }
}

- (NSURLSessionConfiguration*)generateSessionConfig
{
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    if ([self.configuration respondsToSelector:@selector(timeout)]) {
        sessionConfig.timeoutIntervalForRequest = [self.configuration timeout];
    }
    if ([self.configuration respondsToSelector:@selector(requestCachePolicy)]) {
        sessionConfig.requestCachePolicy = [self.configuration requestCachePolicy];
    }
    if ([self.configuration respondsToSelector:@selector(additionalHeaders)]) {
        sessionConfig.HTTPAdditionalHeaders = [self.configuration additionalHeaders];
    }
    if ([self.configuration respondsToSelector:@selector(shouldSetCookies)]) {
        sessionConfig.HTTPShouldSetCookies = [self.configuration shouldSetCookies];
    }
    if ([self.configuration respondsToSelector:@selector(cookieAcceptPolicy)]) {
        sessionConfig.HTTPCookieAcceptPolicy = [self.configuration cookieAcceptPolicy];
    }
    if ([self.configuration respondsToSelector:@selector(cookieStorage)]) {
        sessionConfig.HTTPCookieStorage = [self.configuration cookieStorage];
    }
    if ([self.configuration respondsToSelector:@selector(URLCache)]) {
        sessionConfig.URLCache = [self.configuration URLCache];
    }
    return sessionConfig;
}

- (AFHTTPSessionManager*)newSessionManager
{
    NSURLSessionConfiguration *sessionConfig = [self generateSessionConfig];
    AFHTTPSessionManager *sessionManager = [[AFHTTPSessionManager alloc]initWithSessionConfiguration:sessionConfig];
    
    NSArray *arraySerializers;
    if ([self.configuration respondsToSelector:@selector(responseSerializer)]) {
        SHResponseSerializer serializer = [self.configuration responseSerializer];
        arraySerializers = [self responseSerializer:serializer];
    }
    
    AFCompoundResponseSerializer *resSerializer;
    if (arraySerializers.count) {
        resSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:arraySerializers];
    }else{
        resSerializer = [AFCompoundResponseSerializer serializer];
    }
    
    if ([self.configuration respondsToSelector:@selector(acceptableContentTypes)]) {
        resSerializer.acceptableContentTypes = [self.configuration acceptableContentTypes];
    }
    
    sessionManager.requestSerializer = self.httpReqSerializer;
    sessionManager.responseSerializer = resSerializer;
    return sessionManager;
}

#pragma mark - Getters
- (AFHTTPSessionManager*)manager
{
    AFHTTPSessionManager *manager;
    @synchronized(self.muArrayManagers) {
        if (self.muArrayManagers.count==0) {
            [self.muArrayManagers addObject:[self newSessionManager]];
        }
        manager = [self.muArrayManagers lastObject];
    }
    return manager;
}

- (NSArray*)requestMiddles
{
    if (!_requestMiddles) {
        if ([self.configuration respondsToSelector:@selector(requestMiddlewares)]) {
            _requestMiddles = [self.configuration requestMiddlewares];
        }
    }
    return _requestMiddles;
}

- (NSArray*)responseMiddles
{
    if (!_responseMiddles) {
        if ([self.configuration respondsToSelector:@selector(responseMiddlewares)]) {
            _responseMiddles = [self.configuration responseMiddlewares];
        }
    }
    return _responseMiddles;
}

- (NSMutableArray*)muArrayFrozen
{
    if (!_muArrayFrozen) {
        _muArrayFrozen = [[NSMutableArray alloc]init];
    }
    return _muArrayFrozen;
}

- (AFHTTPRequestSerializer*)httpReqSerializer
{
    if (!_httpReqSerializer) {
        _httpReqSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _httpReqSerializer;
}

- (AFJSONRequestSerializer*)jsonReqSerializer
{
    if (!_jsonReqSerializer) {
        _jsonReqSerializer = [AFJSONRequestSerializer serializer];
    }
    return _jsonReqSerializer;
}

- (AFPropertyListRequestSerializer*)plistReqSerializer
{
    if (!_plistReqSerializer) {
        _plistReqSerializer = [AFPropertyListRequestSerializer serializer];
    }
    return _plistReqSerializer;
}
@end
