//
//  CXXChooseImageViewController.h
//  CXXChooseImage
//
//  Created by Qun on 16/9/30.
//  Copyright © 2016年 Qun. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol CXXChooseImageViewControllerDelegate <NSObject>
@optional
- (void)chooseImageViewControllerDidChangeCollectionViewHeigh:(CGFloat)height;
-(void)pickImages:(NSArray *)imageArr andAllPickPitures:(NSArray *)allPitures;
@end

@interface CXXChooseImageViewController : UIViewController

@property(nonatomic,assign)int flag;
@property (nonatomic, strong) UICollectionView *collectionView;
/** 最大可选择图片个数 */
@property (nonatomic, assign) NSInteger maxImageCount;

/** 选择的图片数据源 */
@property (nonatomic, strong) NSMutableArray *dataArr;
@property (nonatomic, strong) NSMutableArray *pictureWithIndexArray;

@property (nonatomic,strong)NSArray* publicArray;


@property (nonatomic, strong) NSArray *picPathStringsArray;

/** delegate */
@property (nonatomic, weak) id <CXXChooseImageViewControllerDelegate>delegate;

- (void)setOrigin:(CGPoint)origin ItemSize:(CGSize)itemSize rowCount:(NSInteger)rowCount;
@end
