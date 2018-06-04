//
//  AliyunOSSUpload.m
//  YJJSApp
//
//  Created by DT on 2018/3/21.
//  Copyright © 2018年 dt. All rights reserved.
//

#import <AliyunOSSiOS/OSSService.h>
#import <AliyunOSSiOS/OSSCompat.h>
#import "AliyunOSSUpload.h"
#import "IHUtility.h"
#import "NSObject+SBJSON.h"
NSString * const AccessKey = @"XfOiw9ucCNaxHMbL";
NSString * const SecretKey = @"xgZVY4DHfBnlmwGlsWivFDmnYoCMgS";
NSString * const endPoint = @"https://oss-cn-qingdao.aliyuncs.com/";

#define kScreenHeight [UIScreen mainScreen].bounds.size.height//获取屏幕高度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width//获取屏幕宽度
OSSClient * client;
@implementation AliyunOSSUpload
static AliyunOSSUpload *_config;

+(AliyunOSSUpload *)aliyunInit{
    @synchronized(self){
        if (_config==nil) {
            [OSSLog enableLog];
            
            _config=[[AliyunOSSUpload alloc] init];
            id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey
                                                                                                                    secretKey:SecretKey];
            
            
            client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
        }
    }
    return _config;
}



-(void)uploadImage:(NSArray*)imgArr   FileDirectory:(FileType)type  success:(void (^)(NSString *obj))success{
    NSMutableArray *imgArray=[NSMutableArray new];
    for (int i=0; i<imgArr.count; i++) {
        NSData* data;
        
        NSDictionary *imgDictionary = [imgArr objectAtIndex:i];
        NSArray *imgValue = [imgDictionary allValues];
        NSArray *imgKey = [imgDictionary allKeys];
        UIImage *image1 = [imgValue objectAtIndex:0];
        NSString *str = [imgKey objectAtIndex:0];
        UIImage *image=[IHUtility rotateAndScaleImage:image1 maxResolution:(int)kScreenWidth*2];
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.contentType=@"image/jpeg";
        put.bucketName = @"yijiao";
        NSString *imgName;
        if (type==ENT_fileImageHeader) {
            NSData *data1=UIImageJPEGRepresentation(image, 1);
            float length1 = [data1 length]/1024;
            if (length1<600) {
                data = UIImageJPEGRepresentation(image, 1);
            }else{
                if ([IHUtility IsEnableWIFI]) {
                    data = UIImageJPEGRepresentation(image, 0.6);
                }else{
                    data = UIImageJPEGRepresentation(image, 0.5);
                }
            }
            
            imgName=[NSString stringWithFormat:@"ios/header/header_%@.jpg",[IHUtility getTransactionID]];
        }else if (type==ENT_fileImageBody){
            NSData *data1=UIImageJPEGRepresentation(image, 1);
            float length1 = [data1 length]/1024;
            if (length1<600) {
                data = UIImageJPEGRepresentation(image, 1);
            }else{
                data = UIImageJPEGRepresentation(image, 0.5);
            }
            imgName=[NSString stringWithFormat:@"ios/content/body_%@/%@.jpg",str,[IHUtility getNowTimeTimestamp]];
        }else if (type==ENT_fileImageJs)
        {
            NSData *data1=UIImageJPEGRepresentation(image, 1);
            float length1 = [data1 length]/1024;
            if (length1<600) {
                data = UIImageJPEGRepresentation(image, 1);
            }else{
                data = UIImageJPEGRepresentation(image, 0.5);
                
            }
            imgName=[NSString stringWithFormat:@"js/header/header_%@.jpg",[IHUtility getTransactionID]];
        }else if (type==ENT_fileImageProject){
            NSData *data1=UIImageJPEGRepresentation(image, 1);
            float length1 = [data1 length]/1024;
            if (length1<600) {
                data = UIImageJPEGRepresentation(image, 1);
            }else{
                data = UIImageJPEGRepresentation(image, 0.5);
            }
            imgName=[NSString stringWithFormat:@"ios/storePicture/web_%@/%@.jpg",str,[IHUtility getNowTimeTimestamp]];
        }else if (type==ENT_fileItemImageBody){
            NSData *data1=UIImageJPEGRepresentation(image, 1);
            float length1 = [data1 length]/1024;
            if (length1<600) {
                data = UIImageJPEGRepresentation(image, 1);
            }else{
                data = UIImageJPEGRepresentation(image, 0.5);
            }
            imgName=[NSString stringWithFormat:@"ios/web/itemBody_%@/%@.jpg",str,[IHUtility getNowTimeTimestamp]];
        }
        put.objectKey = imgName;
        put.uploadingData = data; // 直接上传NSData
        
        put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
            NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
        };
        
        NSString *imgWidth;
        NSString *imgHeigh;
        if (type==ENT_fileImageHeader) {
            imgWidth=[NSString stringWithFormat:@"%d",(int)kScreenWidth];
            imgHeigh=[NSString stringWithFormat:@"%d",(int)kScreenWidth];
            
        }
        else if (type==ENT_fileImageBody){
            imgWidth=[NSString stringWithFormat:@"%lf",image.size.width];
            imgHeigh=[NSString stringWithFormat:@"%lf",image.size.height];
        } else if (type==ENT_fileImageJs){
            imgWidth=[NSString stringWithFormat:@"%lf",image.size.width];
            imgHeigh=[NSString stringWithFormat:@"%lf",image.size.height];
        }else if (type==ENT_fileImageProject){
            imgWidth=[NSString stringWithFormat:@"%lf",image.size.width];
            imgHeigh=[NSString stringWithFormat:@"%lf",image.size.height];
        }else if (type==ENT_fileItemImageBody){
            imgWidth=[NSString stringWithFormat:@"%lf",image.size.width];
            imgHeigh=[NSString stringWithFormat:@"%lf",image.size.height];
        }
        
        NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"/%@",imgName],@"t_url",
                           imgWidth,@"t_width",
                           imgHeigh,@"t_height",
                           nil];
        [imgArray addObject:dic];
        
        if (client==nil) {
            id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc] initWithPlainTextAccessKey:AccessKey
                                                                                                                    secretKey:SecretKey];
            
            client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
        }
        
        OSSTask * putTask = [client putObject:put];
        
        [putTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                NSLog(@"upload object success!");
                if (type==ENT_fileImageHeader) {
                    NSString *str=[NSString stringWithFormat:@"/%@",imgName];
                    success(str);
                }
                else if (type==ENT_fileImageBody){
                    if (i==imgArr.count-1) {
                        NSString *str=[imgArray JSONRepresentation];
                        success(str);
                    }
                }else if (type==ENT_fileImageJs){
                    success(imgName);
                }
                else if (type==ENT_fileImageProject){
                    if (i==imgArr.count-1) {
                        NSString *str=[imgArray JSONRepresentation];
                        success(str);
                    }
                }else if (type==ENT_fileItemImageBody){
                    success(imgName);
                }
            } else{
               // [YJTipView showBottomWithText:@"图片上传失败,请重试" bottomOffset:300 duration:1.5f];
                NSLog(@"upload object failed, error: %@" , task.error);
            }
            return nil;
        }];
    }
}

@end

