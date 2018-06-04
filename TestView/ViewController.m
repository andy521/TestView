//
//  ViewController.m
//  TestView
//
//  Created by DT on 2018/5/25.
//  Copyright © 2018年 dt. All rights reserved.
//

#import "ViewController.h"
#import "AliyunOSSUpload.h"
#import "CXXChooseImageViewController.h"
#import "UIViewAdditions.h"
#import "JSON.h"
#define kScreenHeight [UIScreen mainScreen].bounds.size.height//获取屏幕高度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width//获取屏幕宽度

@interface ViewController ()<CXXChooseImageViewControllerDelegate>
@property (nonatomic, strong) CXXChooseImageViewController *vc;
@end

@implementation ViewController
{
     NSMutableArray * _allPickPitures;
       UIButton *finishBtn;//保存
}
- (void)viewDidLoad {
    [super viewDidLoad];

    //门店照片
    CXXChooseImageViewController *vc = [[CXXChooseImageViewController alloc] init];
    vc.delegate = self;
    vc.flag =100;
    self.vc = vc;
    [self addChildViewController:vc];
    CGFloat photoWith =(kScreenWidth -80)/3;
    [vc setOrigin:CGPointMake(5,50) ItemSize:CGSizeMake(photoWith, photoWith*110/150) rowCount:3];
    NSMutableArray *photosArr = [[NSMutableArray alloc]init];
    vc.publicArray = photosArr;
    [self.view insertSubview:vc.view atIndex:[self.view subviews].count];
    vc.maxImageCount = 9;
    
    finishBtn=[[UIButton alloc]initWithFrame:CGRectMake((kScreenWidth-(185*kScreenWidth/375))/2, vc.view.bottom+50, 185*kScreenWidth/375, 45)];
    [finishBtn setTitle:@"保存" forState:UIControlStateNormal];
    finishBtn.backgroundColor = [UIColor redColor];
    finishBtn.layer.cornerRadius = 45/2;
    finishBtn.layer.masksToBounds = YES;
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(finishClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:finishBtn];
}
#pragma  CXXChooseImageViewController代理方法
- (void)chooseImageViewControllerDidChangeCollectionViewHeigh:(CGFloat)height{
    
    self.vc.view.frame =  CGRectMake(0,60,kScreenWidth, height);
    finishBtn.frame = CGRectMake((kScreenWidth-(185*kScreenWidth/375))/2, self.vc.view.bottom+50, 185*kScreenWidth/375, 45);
    
}
-(void)pickImages:(NSArray *)imageArr andAllPickPitures:(NSArray *)allPitures
{
    _allPickPitures =  [[NSMutableArray alloc]initWithArray:allPitures];
}
//点击保存
-(void)finishClick{
    NSMutableArray *publicArray = [[NSMutableArray alloc]init];
    NSMutableArray *pickArray = [[NSMutableArray alloc]init];
    if(_allPickPitures.count>0)
    {
        for(id data in _allPickPitures)
        {
            if([data isKindOfClass:[NSString class]])
            {
                [publicArray addObject:data];
            }else if ([data isKindOfClass:[UIImage class]])
            {
                NSMutableDictionary *pictureDict = [[NSMutableDictionary alloc]init];
                [pictureDict setObject:data forKey:[NSString stringWithFormat:@"%ld",(long)[_allPickPitures indexOfObject:data]]];
                [pickArray addObject:pictureDict];
            }
        }
    }
     [AliyunUpload uploadImage:pickArray FileDirectory:ENT_fileImageProject success:^(NSString *obj) {
         
         NSArray *objArray = (NSArray*)[obj  JSONValue];
         if(objArray && objArray.count>0){
             for(NSDictionary *dic in objArray){
                 NSString *t_url = dic[@"t_url"];
                 NSString *url = [t_url substringFromIndex:1];//[NSString stringWithFormat:@"%@%@",Upload_url_write,[t_url substringFromIndex:1]];
                 [publicArray addObject:url];
             }
         }
         NSLog(@"阿里云上传图片%@",publicArray);
     }];
}
@end
