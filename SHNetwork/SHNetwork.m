//
//  SHNetwork.m
//  SHNetwork
//
//  Created by Hayden on 15/11/25.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import "SHNetwork.h"

@interface SHNetwork ()

@end

@implementation SHNetwork
+ (SHNetworkMethod)methodWithString:(nonnull NSString*)method
{
    NSString *strUp = [method uppercaseString];
    if ([strUp isEqualToString:@"POST"]) {
        return SHNetworkPost;
    }else if([strUp isEqualToString:@"DELETE"]){
        return SHNetworkDelete;
    }else if([strUp isEqualToString:@"HEAD"]){
        return SHNetworkHead;
    }else if([strUp isEqualToString:@"PUT"]){
        return SHNetworkPut;
    }else if([strUp isEqualToString:@"PATCH"]){
        return SHNetworkPatch;
    }else{
        return SHNetworkGet;
    }
}

+ (nonnull SHRequest*)request
{
    return [SHRequest instance];
}

+ (nonnull SHDownload*)download
{
    return [SHDownload instance];
}

+ (nonnull SHUpload*)upload
{
    return [SHUpload instance];
}
@end


