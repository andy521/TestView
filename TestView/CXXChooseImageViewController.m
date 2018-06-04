//
//  CXXChooseImageViewController.m
//  CXXChooseImage
//
//  Created by Qun on 16/9/30.
//  Copyright © 2016年 Qun. All rights reserved.
//

#import "CXXChooseImageViewController.h"
#import "TZImagePickerController.h"
#import "CXXPhotoCell.h"
#import "UIViewAdditions.h"
#import "SDPhotoBrowser.h"
#import "UIImage+KIAdditions.h"
#import "UIImageView+WebCache.h"
#define kScreenHeight [UIScreen mainScreen].bounds.size.height//获取屏幕高度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width//获取屏幕宽度
#define Upload_url_write            @"http://yijiao.oss-cn-qingdao.aliyuncs.com/"
//#import "PickBrowserViewController.h"

//#define self.itemSpace 10
//#define rowCount 4

@interface CXXChooseImageViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, CXXPhotoCellDelegate, UIActionSheetDelegate, TZImagePickerControllerDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,SDPhotoBrowserDelegate>
/** layout */
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;


/** 点击的第几个item */
@property (nonatomic, strong) NSIndexPath *selectIndexPath;

/** 每一行多少个 */
@property (nonatomic, assign) NSInteger rowCount;
/**  itemSize*/
@property (nonatomic, assign) CGSize itemSize;
/** 间距 */
@property (nonatomic, assign) CGFloat itemSpace;
@end

@implementation CXXChooseImageViewController

static NSString * const photoID = @"photoCellID";
- (instancetype)init{
    self = [super init];
    if (self) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        self.layout = layout;
    }
    return self;
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"delectPicture" object:nil];
}
- (void)viewDidLoad {
    [super viewDidLoad];
   
    //删除图片
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delectPaicture:) name:@"delectPicture" object:nil];
    self.layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0,kScreenWidth, kScreenHeight) collectionViewLayout:self.layout];
    
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight |UIViewAutoresizingFlexibleWidth;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CXXPhotoCell"bundle:nil] forCellWithReuseIdentifier:photoID];
}

// 删除照片
- (void)delectPaicture:(NSNotification *)notification{
    NSDictionary *dict = notification.object;
    NSInteger currentIndex = [[dict valueForKey:@"index"] integerValue];
    if (self.dataArr.count > 0) {
        [self.dataArr removeObjectAtIndex:currentIndex];
    }
    [self.collectionView reloadData];
    [self resetHeight];
}
#pragma mark - collect数据源
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (self.dataArr.count >= self.maxImageCount) {
        return self.maxImageCount;
    }
    return self.dataArr.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    CXXPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:photoID forIndexPath:indexPath];
    cell.delegate = self;
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 5;
    if (cell == nil) {
        cell = [[CXXPhotoCell alloc]init];
    }
    NSString *pictureStr ;
    if(self.flag==100){
        cell.photoImage.frame  = CGRectMake(0, 0, 96,  71);
        pictureStr =@"setting_display_icon_add";
    }else
    {
        pictureStr =@"setting_display_icon_add";
        cell.photoImage.frame  = CGRectMake(0, 0,110,  150);
    }
    if(self.dataArr.count == 0){
         cell.photoImage.image = [UIImage imageNamed:pictureStr];
    }else{
        if(indexPath.item <= self.dataArr.count - 1)
        {
            if([self.dataArr[indexPath.item] isKindOfClass:[NSString class]])
            {
                NSString *pitureUrl = [NSString stringWithFormat:@"%@%@",Upload_url_write,self.dataArr[indexPath.item]];
                 [cell.photoImage sd_setImageWithURL:[NSURL URLWithString:pitureUrl] placeholderImage: [UIImage imageNamed:@""]];
            }else
            {
                cell.photoImage.image = self.dataArr[indexPath.item];
            }
        }else
        {
            cell.photoImage.image = [UIImage imageNamed:pictureStr];
        }
        //cell.photoImg = indexPath.item <= self.dataArr.count - 1 ? self.dataArr[indexPath.item] : nil;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    self.selectIndexPath = indexPath;
    if(self.dataArr.count>0)
    {
       if(indexPath.row==self.dataArr.count)
       {
           UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"请选择相机或者相册" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打开相机",@"打开相册",nil];
           [action showInView:self.view];
       }else
       {
           SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
           browser.currentImageIndex = indexPath.row ;
           browser.sourceImagesContainerView = self.collectionView;
           //NSArray *pictures = [self.model.contentPicture componentsSeparatedByString:@","];
           //browser.imageCount = pictures.count;
           browser.imageCount = self.dataArr.count;
           browser.delegate = self;
           [browser show];
       }
    }else
    {
        UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:@"请选择相机或者相册" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"打开相机",@"打开相册",nil];
        [action showInView:self.view];
    }
}
#pragma mark - 打开相机 相册
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self openCamera];
            break;
        case 1:
            [self openAlbum];
            break;
        default:
            break;
    }
}
- (void)openCamera
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        ipc.delegate = self;
        [self presentViewController:ipc animated:YES completion:nil];
    } else {
//        [self showHint:@"请打开允许访问相机权限"];
        NSLog(@"请打开允许访问相机权限");
    }
}
- (void)openAlbum
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:self.maxImageCount - self.selectIndexPath.item delegate:self];
        [self presentViewController:imagePickerVc animated:YES completion:nil];
    }else{
//        [self showHint:@"请打开允许访问相册权限"];
        NSLog(@"请打开允许访问相册权限");
    }
}
#pragma mark - UIImagePickerControllerDelegate
//相机选的图片
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    // 关闭相册\相机
    UIImage * img=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    img=[UIImage rotateImage:img];
    [picker dismissViewControllerAnimated:YES completion:nil];
    // 往数据数组拼接图片
    [self.dataArr addObject:info[UIImagePickerControllerOriginalImage]];

    //保存oss的资源
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict setObject:info[UIImagePickerControllerOriginalImage] forKey:[NSString stringWithFormat:@"%ld",(long)self.dataArr.count-1]];
    [self.pictureWithIndexArray addObject:dict];
    [self reloadData];
}
//取消按钮
- (void)imagePickerControllerDidCancel:(TZImagePickerController *)picke{
    [self dismissViewControllerAnimated:YES completion:nil];
}
// 相册选的图片
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto{
    
    for (int i = 0;i < photos.count;i++) {
        UIImage *image = photos[i];
        [self.dataArr addObject:image];
      
        //保存oss的资源
        NSMutableDictionary *pictureDict = [[NSMutableDictionary alloc]init];
        [pictureDict setObject:[UIImage rotateImage:image] forKey:[NSString stringWithFormat:@"%ld",(long)self.dataArr.count-1]];
        [self.pictureWithIndexArray addObject:pictureDict];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
   
}

#pragma mark - set方法
- (void)setOrigin:(CGPoint)origin ItemSize:(CGSize)itemSize rowCount:(NSInteger)rowCount{
    self.rowCount = rowCount;
    self.itemSize = itemSize;
    CGFloat itemSpace = (kScreenWidth - itemSize.width * rowCount) / (rowCount + 1);
    self.itemSpace = itemSpace;
    self.layout.itemSize = itemSize;
    self.layout.minimumLineSpacing = itemSpace;
    self.layout.minimumInteritemSpacing = itemSpace;
    self.layout.sectionInset = UIEdgeInsetsMake(itemSpace, itemSpace, itemSpace, itemSpace);
    self.view.frame = CGRectMake(origin.x, origin.y, kScreenWidth-2*origin.x, itemSize.width + 2 * itemSpace+150);

}
- (void)setMaxImageCount:(NSInteger)maxImageCount{
    _maxImageCount = maxImageCount;
    [self.collectionView reloadData];
}

-(void)setPublicArray:(NSArray *)publicArray
{
    _publicArray = publicArray;
    
    //获取网络图片
    [self.dataArr addObjectsFromArray:_publicArray];
   [self resetHeight];
}

- (NSMutableArray *)dataArr{
    if (_dataArr == nil) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}
- (NSMutableArray *)pictureWithIndexArray{
    if (_pictureWithIndexArray == nil) {
        _pictureWithIndexArray = [[NSMutableArray alloc] init];
    }
    return _pictureWithIndexArray;
}
- (void)reloadData{
    // 大于maxImageCount条的删除
    if (self.dataArr.count > self.maxImageCount) {
        NSRange range = NSMakeRange(self.maxImageCount, self.dataArr.count - self.maxImageCount);
        [self.dataArr removeObjectsInRange:range];
    }
    [self.collectionView reloadData];
    
    [self resetHeight];
    
}
// 重置高度
- (void)resetHeight{
    
    NSInteger count = self.dataArr.count / self.rowCount + 1; // 行数
    CGFloat height = (count + 1) *  self.itemSpace + count * self.itemSize.height;
    
    if ([self.delegate respondsToSelector:@selector(chooseImageViewControllerDidChangeCollectionViewHeigh:)]) {
        [self.delegate chooseImageViewControllerDidChangeCollectionViewHeigh:height];
        [self.delegate pickImages:self.pictureWithIndexArray andAllPickPitures:self.dataArr];
    }
    self.collectionView.height = height;
}

//本地图片
- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    if(index<self.dataArr.count)
    {
        if([self.dataArr[index] isKindOfClass:[UIImage class]])
        {
            UIImage *imageView = self.dataArr[index];
            return imageView;
        }
        return nil;
    }else
    {
        return nil;
    }
}
//网络图片
- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    if(index<self.dataArr.count)
    {
        if([self.dataArr[index] isKindOfClass:[NSString class]])
        {
              NSString *pitureUrl = [NSString stringWithFormat:@"%@%@",Upload_url_write,self.dataArr[index]];
            NSURL *url= [NSURL URLWithString:pitureUrl];
              return url;
        }
        return nil;
    }else
    {
        return nil;
    }
}
@end
