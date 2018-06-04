//
//  CXXPhotoCell.h
//  chexiaoxi
//
//  Created by Qun on 16/6/29.
//  Copyright © 2016年 IOS. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CXXPhotoCell;
@protocol CXXPhotoCellDelegate <NSObject>
@optional
- (void)photoCellRemovePhotoBtnClickForCell:(CXXPhotoCell *)cell;
@end
@interface CXXPhotoCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;
/** 传递过来的图片 */
@property (nonatomic, strong) UIImage *photoImg;
/** <#name#> */
@property (nonatomic, weak) id <CXXPhotoCellDelegate>delegate;
@end
