//
//  SHDownload.m
//  SHNetwork
//
//  Created by Hayden on 15/12/1.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHDownload.h"
#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>

static SHDownload *__instance;
extern dispatch_queue_t base_network_progress_queue();

@interface SHBaseRequest (Protected)

@property (nonatomic, strong, nullable) AFHTTPSessionManager *manager;
@property (nonatomic, strong, nonnull) NSMapTable *taskSessionMap;

- (void)nextRequestMiddleware:(SHNetworkTask*)task next:(NSInteger)next error:(NSError*)error;
- (void)nextResponseMiddleware:(SHNetworkTask*)task response:(NSURLResponse*)response responseObject:(id)responseObject error:(NSError*)error next:(NSInteger)next;
- (void)removeTask:(SHNetworkTask*)task;
- (id<AFURLRequestSerialization>)requestSerializerWithOption:(SHRequestSerializer)serializer;
@end

@interface SHDownload ()

@end

@implementation SHDownload
+ (nonnull SHDownload*)instance
{
    if (!__instance) {
        __instance = [[SHDownload alloc]init];
    }
    return __instance;
}

#pragma mark - Public Methods - Request
- (void)requester:(id)requester get:(NSString*)url params:(id)params progress:(SHNetworkProgress)progress success:(SHNetworkSuccess)success failure:(SHNetworkFailure)failure
{
    NSString *destiation = [self randomFileDestiation];
    [self requester:requester get:url params:params destination:destiation progress:progress success:success failure:failure];
}

- (void)requester:(id)requester get:(NSString *)url params:(id)params destination:(NSString*)destination progress:(SHNetworkProgress)progress success:(SHNetworkSuccess)success failure:(SHNetworkFailure)failure
{
    [self requester:requester method:SHNetworkGet url:url params:params destination:destination progress:progress success:success failure:failure];
}

- (void)requester:(id)requester post:(NSString*)url params:(id)params progress:(SHNetworkProgress)progress success:(SHNetworkSuccess)success failure:(SHNetworkFailure)failure
{
    NSString *destiation = [self randomFileDestiation];
    [self requester:requester post:url params:params destination:destiation progress:progress success:success failure:failure];
}

- (void)requester:(id)requester post:(NSString*)url params:(id)params destination:(NSString*)destination progress:(SHNetworkProgress)progress success:(SHNetworkSuccess)success failure:(SHNetworkFailure)failure
{
    [self requester:requester method:SHNetworkPost url:url params:params destination:destination progress:progress success:success failure:failure];
}

#pragma mark - Private Methods - Request
- (void)requester:(id)requester method:(SHNetworkMethod)method url:(NSString*)url params:(id)params destination:(NSString*)destination progress:(SHNetworkProgress)progress success:(SHNetworkSuccess)success failure:(SHNetworkFailure)failure
{
    SHDownloadTask *task = [[SHDownloadTask alloc]init];
    task.requester = requester;
    task.url = url;
    task.params = params;
    task.method = method;
    task.successBlock = success;
    task.failureBlock = failure;
    task.progressBlock = progress;
    task.destination = destination;
    [self nextRequestMiddleware:task next:0 error:nil];
}

- (void)requestWithTask:(SHDownloadTask*)task
{
    [self nextRequestMiddleware:task next:0 error:nil];
}

#pragma mark - Private Methods - Submit Request
- (void)submitRequest:(SHNetworkTask*)task
{
    SHDownloadTask *strongTask = (SHDownloadTask*)task;
    __weak SHDownloadTask *weakTask = strongTask;
    
    __strong id requestor = strongTask.requester;
    if (requestor == nil) {
        [self removeTask:strongTask];
        return;
    }
    
    AFHTTPSessionManager *manager = self.manager;
    manager.requestSerializer = [self requestSerializerWithOption:strongTask.requestSerializer];
    NSMutableURLRequest *request;
    NSError *error;
    if (strongTask.method == SHNetworkPost) {
        request = [manager.requestSerializer requestWithMethod:@"POST" URLString:strongTask.url parameters:strongTask.params error:&error];
    }else{
        request = [manager.requestSerializer requestWithMethod:@"GET" URLString:strongTask.url parameters:strongTask.params error:&error];
    }
    
    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            task.failureBlock(nil, error);
            [self removeTask:task];
        });
        return;
    }
    
    NSURLSessionDownloadTask *downLoadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        if (weakTask.progressBlock) {
            weakTask.progressBlock(downloadProgress.fractionCompleted);
        }
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        NSString *destination = strongTask.destination;
        [self createFolderIfNeed:[destination stringByDeletingLastPathComponent]];
        NSString *last = [destination lastPathComponent];
        if (response.suggestedFilename && [response.suggestedFilename rangeOfString:@"."].location != NSNotFound && [last rangeOfString:@"."].location == NSNotFound) {
            NSString *fileExtension = [[response.suggestedFilename componentsSeparatedByString:@"."] lastObject];
            destination = [NSString stringWithFormat:@"%@.%@", destination, fileExtension];
        }
        
        NSURL *path = [NSURL fileURLWithPath:destination];
        return path;
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        [self nextResponseMiddleware:strongTask response:response responseObject:filePath.path error:error next:0];
    }];
    
    @synchronized(self.taskSessionMap) {
        [self.taskSessionMap setObject:downLoadTask forKey:strongTask];
    }
    
    [downLoadTask resume];
}

#pragma mark - Private Methods - Utils
- (NSString*)defaultDestinationRoot
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDir = paths.firstObject;
    return [cachesDir stringByAppendingPathComponent:@"SHNetworkDownloadCache"];
}

- (NSString*)randomFileDestiation
{
    NSString *strCacheRoot = [self defaultDestinationRoot];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString *folder = [formatter stringFromDate:date];
    strCacheRoot = [strCacheRoot stringByAppendingPathComponent:folder];
    
    NSUInteger random = arc4random() % 10000000;
    NSString *strRandom = [self random32String];
    strRandom = [NSString stringWithFormat:@"%lu%@%lf",random, strRandom , date.timeIntervalSince1970];
    strRandom = [self md5:strRandom];
    return [strCacheRoot stringByAppendingPathComponent:strRandom];
}

- (NSString *)md5:(NSString *)string
{
    const char *cStr = [string UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_LONG lenght = (CC_LONG)strlen(cStr);
    CC_MD5(cStr, lenght, result);
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

- (NSString *)random32String
{
    char data[32];
    for (int x=0;x< 32;data[x++] = (char)('A' + (arc4random_uniform(26))));
    return [[NSString alloc] initWithBytes:data length:32 encoding:NSUTF8StringEncoding];
}

- (void)createFolderIfNeed:(NSString*)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:path isDirectory:&isDir];
    if(!(isDirExist && isDir)){
        [self createFolderIfNeed:[path stringByDeletingLastPathComponent]];
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}
@end
