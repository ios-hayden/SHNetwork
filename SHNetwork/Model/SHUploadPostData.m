//
//  SHUploadPostData.m
//  SHNetwork
//
//  Created by Hayden on 15/12/2.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHUploadPostData.h"

@interface SHUploadPostData ()

@end

@implementation SHUploadPostData
- (instancetype)init
{
    self = [super init];
    if (self) {
        _postData = [[NSMutableDictionary alloc]initWithCapacity:6];
    }
    return self;
}

#pragma mark - Public Methods
- (void)setData:(NSData*)data forKey:(NSString*)key
{
    [self setData:data withStringMineType:nil forKey:key];
}

- (void)setData:(NSData*)data withMineType:(SHUploadFileMineType)mineType forKey:(NSString*)key
{
    [self setData:data withFileName:nil mineType:mineType forKey:key];
}

- (void)setData:(NSData*)data withStringMineType:(NSString*)mineType forKey:(NSString*)key
{
    [self setData:data withFileName:nil stringMineType:mineType forKey:key];
}

- (void)setData:(NSData*)data withFileName:(NSString*)fileName mineType:(SHUploadFileMineType)mineType forKey:(NSString*)key
{
    NSString *stringMineType = (mineType<SH_UPLOAD_MINETYPES.count ? SH_UPLOAD_MINETYPES[mineType] : nil);
    [self setData:data withFileName:fileName stringMineType:stringMineType forKey:key];
}

- (void)setData:(NSData*)data withFileName:(NSString*)fileName stringMineType:(NSString*)mineType forKey:(NSString*)key
{
    if (data==nil || key.length==0) {
        return;
    }
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithCapacity:3];
    [dic setObject:data forKey:@"data"];
    mineType = mineType.length ? mineType : @"";
    [dic setObject:mineType forKey:@"mineType"];
    if (fileName.length) {
        [dic setObject:fileName forKey:@"fileName"];
    }
    if ([_postData objectForKey:key]) {
        [_postData removeObjectForKey:key];
    }
    [_postData setObject:dic forKey:key];
}

- (void)dealloc
{
    
}
@end
