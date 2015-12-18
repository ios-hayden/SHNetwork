//
//  SHUploadPostData.h
//  SHNetwork
//
//  Created by Hayden on 15/12/2.
//  Copyright © 2015年 Hayden. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SHUploadFileMineType) {
    SHUploadFileZip = 0,
    SHUploadFileJpg,
    SHUploadFilePng,
    SHUploadFileJpeg,
    SHUploadFileGif,
    SHUploadFileTar,
    SHUploadFileXml,
    SHUploadFileText,
    SHUploadFileHtml,
    SHUploadFilePdf,
    SHUploadFileMpeg,
    SHUploadFileAvi,
    SHUploadFileRm,
    SHUploadFileRmvb,
    SHUploadFileWmv,
    SHUploadFileFlv,
    SHUploadFileMp3,
    SHUploadFileWav,
    SHUploadFileWma,
    SHUploadFileDoc,
    SHUploadFilePpt,
    SHUploadFileXls
};

@interface SHUploadPostData : NSObject
@property (nonatomic, strong, readonly, nonnull) NSMutableDictionary *postData;

- (void)setData:(nonnull NSData*)data forKey:(nonnull NSString*)key;

- (void)setData:(nonnull NSData*)data withMineType:(SHUploadFileMineType)mineType forKey:(nonnull NSString*)key;

- (void)setData:(nonnull NSData*)data withStringMineType:(nullable NSString*)mineType forKey:(nonnull NSString*)key;

- (void)setData:(nonnull NSData*)data withFileName:(nullable NSString*)fileName mineType:(SHUploadFileMineType)mineType forKey:(nonnull NSString*)key;

- (void)setData:(nonnull NSData*)data withFileName:(nullable NSString*)fileName stringMineType:(nullable NSString*)mineType forKey:(nonnull NSString*)key;
@end

#define SH_UPLOAD_MINETYPES @[ \
@"application/zip", \
@"image/jpeg", \
@"image/png", \
@"image/pjpeg", \
@"image/gif", \
@"application/x-tar", \
@"application/xhtml+xml", \
@"text/plain", \
@"text/html", \
@"application/pdf", \
@"video/mpeg", \
@"video/avi", \
@"video/rm", \
@"video/rmvb", \
@"video/x-ms-wmv", \
@"audio/mp3", \
@"audio/wav", \
@"audio/x-ms-wma", \
@"video/quicktime", \
@"application/msword", \
@"application/vnd.ms-powerpoint", \
@"application/vnd.ms-excel"]
