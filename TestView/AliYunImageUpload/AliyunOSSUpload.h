//
//  AliyunOSSUpload.h
//  YJJSApp
//
//  Created by DT on 2018/3/21.
//  Copyright © 2018年 dt. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define AliyunUpload                [AliyunOSSUpload aliyunInit]
typedef enum{
    ENT_fileImageHeader,//头像
    ENT_fileImageBody,//个人图片
    ENT_fileImageProject,//门店图片
    ENT_fileImageJs,//技师展示图片
    ENT_fileItemImageBody,//门店项目图片
}FileType;
@interface AliyunOSSUpload : NSObject

+(AliyunOSSUpload *)aliyunInit;

-(void)uploadImage:(NSArray*)imgArr   FileDirectory:(FileType)type  success:(void (^)(NSString *obj))success;
@end
