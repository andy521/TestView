//
//  CXXPhotoCell.m
//  chexiaoxi
//
//  Created by Qun on 16/6/29.
//  Copyright © 2016年 IOS. All rights reserved.
//

#import "CXXPhotoCell.h"

@interface CXXPhotoCell()

@property (weak, nonatomic) IBOutlet UIButton *addImageBtn;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;


@end
@implementation CXXPhotoCell
- (void)awakeFromNib {
    [super awakeFromNib];
    [self.photoImage setClipsToBounds:YES];
    [self.photoImage  setContentMode:UIViewContentModeScaleAspectFill];
    self.contentView.backgroundColor = [UIColor whiteColor];
}


//- (void)setPhotoImg:(UIImage *)photoImg{
//    _photoImg = photoImg;
//    if (photoImg == nil) {
//        self.photoImage.image = [UIImage imageNamed:@"setting_display_icon_add"];
//
////        [self.addImageBtn setImage:[UIImage imageNamed:@"setting_display_icon_add"] forState:UIControlStateNormal];
////        self.addImageBtn.userInteractionEnabled = NO;
////        self.closeBtn.hidden = YES;
//    }else{
//        [self.addImageBtn setImage:photoImg forState:UIControlStateNormal];
//    }
//}



- (IBAction)closeBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(photoCellRemovePhotoBtnClickForCell:)]) {
        [self.delegate photoCellRemovePhotoBtnClickForCell:self];
    }
}

@end
