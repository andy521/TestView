//
//  SDPhotoBrowser.m
//  photobrowser
//
//  Created by aier on 15-2-3.
//  Copyright (c) 2015年 aier. All rights reserved.
//

#import "SDPhotoBrowser.h"
#import "UIImageView+WebCache.h"
#import "SDBrowserImageView.h"
#import "CXXPhotoCell.h"
//  ============在这里方便配置样式相关设置===========

//                      ||
//                      ||
//                      ||
//                     \\//
//                      \/

#import "SDPhotoBrowserConfig.h"
#define kScreenHeight [UIScreen mainScreen].bounds.size.height//获取屏幕高度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width//获取屏幕宽度
//  =============================================

@implementation SDPhotoBrowser 
{
    UIScrollView *_scrollView;
    BOOL _hasShowedFistView;
    UILabel *_indexLabel;
    UIButton *_delectButton;
    UIButton *_backButton;
    UIActivityIndicatorView *_indicatorView;
    UIPageControl *_pageControl;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      
        [[UIApplication sharedApplication] setStatusBarHidden: YES withAnimation:UIStatusBarAnimationFade];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)didMoveToSuperview
{
     [self setupScrollView];
    [self setupToolbars];
}

- (void)dealloc
{
    [[UIApplication sharedApplication].keyWindow removeObserver:self forKeyPath:@"frame"];
}

- (void)setupToolbars
{
    // 1. 序标
    UILabel *indexLabel = [[UILabel alloc] init];
     indexLabel.bounds = CGRectMake(0,5+20, 80, 30);
    indexLabel.textAlignment = NSTextAlignmentCenter;
    indexLabel.textColor = [UIColor whiteColor];
    indexLabel.font = [UIFont boldSystemFontOfSize:20];
    indexLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    indexLabel.layer.cornerRadius = indexLabel.bounds.size.height * 0.5;
    indexLabel.clipsToBounds = YES;
   if (self.imageCount >0) {
        indexLabel.text = [NSString stringWithFormat:@"%ld/%ld", (long)self.currentImageIndex+1,(long)self.imageCount];
    }
    _indexLabel = indexLabel;
    [self addSubview:indexLabel];
    
        // 2.删除
    UIButton *delectButton = [[UIButton alloc]initWithFrame:CGRectMake(kScreenWidth-50, 25, 32, 32)];
        [delectButton setBackgroundImage:[UIImage imageNamed:@"delect.png"] forState:UIControlStateNormal];
        [delectButton addTarget:self action:@selector(delectImage) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:delectButton];
        _delectButton =delectButton;
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(20, 5+20, 20, 20)];
    [backButton setBackgroundImage:[UIImage imageNamed:@"zuo_hort.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backPage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backButton];
    _backButton =backButton;
    
//    UIPageControl* pageCtrl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.height-30,self.width, 25)];  //创建UIPageControl，位置在屏幕最下方。
//    pageCtrl.numberOfPages = self.imageCount;//总的图片页数
//    pageCtrl.currentPage = 0; //当
//    _pageControl=pageCtrl;
//    pageCtrl.pageIndicatorTintColor = RGBA(255, 255, 255, 0.4);
//    pageCtrl.currentPageIndicatorTintColor = [UIColor whiteColor];
//    [self addSubview:pageCtrl];
//    if (self.imageCount<2) {
//        pageCtrl.hidden=YES;
//    }
    
    UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
   // longPressGr.minimumPressDuration = 1.0;
    [self addGestureRecognizer:longPressGr];
}
//返回
-(void)backPage
{
    [self photoClick:nil];
}
//删除图片
-(void)delectImage
{
    if(self.imageCount>3){
        [self photoClick:nil];
        NSDictionary *dict = @{@"index":[NSNumber numberWithInteger:self.currentImageIndex]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"delectPicture" object:dict];
    }else
    {
        NSLog(@"门店图片最少要留3张哦");
    }
 
}
-(void)longPressToDo:(UILongPressGestureRecognizer *)tap{
    if(tap.state == UIGestureRecognizerStateBegan)
    {
        HJCActionSheet *sheet = [[HJCActionSheet alloc] initWithDelegate:self CancelTitle:@"取消" OtherTitles: @"下载", nil];
    // 2.显示出来
        [sheet show];
    }
    
}

- (void)actionSheet:(HJCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==1) {
        [self saveImage];
    }
}

- (void)saveImage
{
    int index = _scrollView.contentOffset.x / _scrollView.bounds.size.width;
    UIImageView *currentImageView = _scrollView.subviews[index];
    
    UIImageWriteToSavedPhotosAlbum(currentImageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] init];
    indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    indicator.center = self.center;
    _indicatorView = indicator;
    [[UIApplication sharedApplication].keyWindow addSubview:indicator];
    [indicator startAnimating];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [_indicatorView removeFromSuperview];
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
    label.layer.cornerRadius = 5;
    label.clipsToBounds = YES;
    label.bounds = CGRectMake(0, 0, 150, 30);
    label.center = self.center;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:17];
    [[UIApplication sharedApplication].keyWindow addSubview:label];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:label];
    if (error) {
        label.text = SDPhotoBrowserSaveImageFailText;
    }   else {
        label.text = SDPhotoBrowserSaveImageSuccessText;
    }
    [label performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

- (void)setupScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    [self addSubview:_scrollView];
    
    for (int i = 0; i < self.imageCount; i++) {
        SDBrowserImageView *imageView = [[SDBrowserImageView alloc] init];
        imageView.tag = i;

        // 单击图片
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(photoClick:)];
        
        // 双击放大图片
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewDoubleTaped:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [imageView addGestureRecognizer:singleTap];
        [imageView addGestureRecognizer:doubleTap];
        [_scrollView addSubview:imageView];
    }
    
    [self setupImageOfImageViewForIndex:self.currentImageIndex];
    
}

// 加载图片
- (void)setupImageOfImageViewForIndex:(NSInteger)index
{
    SDBrowserImageView *imageView = _scrollView.subviews[index];
    if (imageView.hasLoadedImage) return;
    if ([self highQualityImageURLForIndex:index]) {
        [imageView setImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
    } else {
        imageView.image = [self placeholderImageForIndex:index];
    }
    imageView.hasLoadedImage = YES;
}

- (void)photoClick:(UITapGestureRecognizer *)recognizer
{
    _scrollView.hidden = YES;
     [[UIApplication sharedApplication] setStatusBarHidden: NO withAnimation:UIStatusBarAnimationFade];
    SDBrowserImageView *currentImageView = (SDBrowserImageView *)recognizer.view;
    NSInteger currentIndex = currentImageView.tag;
    //删除已经删除的cell
    NSMutableArray *viewArray = [[NSMutableArray alloc]init];
    for(id view in self.sourceImagesContainerView.subviews)
    {
        if([view isKindOfClass:[UICollectionViewCell class]])
        {
            CXXPhotoCell *cell = view;
            if(!cell.hidden)
            {
                [viewArray addObject:view];
            }
        }
    }
    
    UIView *sourceView = viewArray[currentIndex];
    CGRect targetTemp = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = currentImageView.image;
    CGFloat h = (self.bounds.size.width / currentImageView.image.size.width) * currentImageView.image.size.height;
    
    if (!currentImageView.image) { // 防止 因imageview的image加载失败 导致 崩溃
        h = self.bounds.size.height;
    }
    
    tempView.bounds = CGRectMake(0, 0, self.bounds.size.width, h);
    tempView.center = self.center;
    
    [self addSubview:tempView];

    _delectButton.hidden = YES;
    _indexLabel.hidden=YES;
    _backButton.hidden = YES;
    [UIView animateWithDuration:SDPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)imageViewDoubleTaped:(UITapGestureRecognizer *)recognizer
{
    SDBrowserImageView *imageView = (SDBrowserImageView *)recognizer.view;
    CGFloat scale;
    if (imageView.isScaled) {
        scale = 1.0;
    } else {
        scale = 2.0;
    }
    SDBrowserImageView *view = (SDBrowserImageView *)recognizer.view;
    [view doubleTapTOZommWithScale:scale];
    if (scale == 1) {
        [view clear];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect rect = self.bounds;
    rect.size.width += SDPhotoBrowserImageViewMargin * 2;
    _scrollView.bounds = rect;
    _scrollView.center = self.center;
    CGFloat y = 0;
    CGFloat w = _scrollView.frame.size.width - SDPhotoBrowserImageViewMargin * 2;
    CGFloat h = _scrollView.frame.size.height;
    [_scrollView.subviews enumerateObjectsUsingBlock:^(SDBrowserImageView *obj, NSUInteger idx, BOOL *stop) {
        CGFloat x = SDPhotoBrowserImageViewMargin + idx * (SDPhotoBrowserImageViewMargin * 2 + w);
        obj.frame = CGRectMake(x, y, w, h);
    }];
    _scrollView.contentSize = CGSizeMake(_scrollView.subviews.count * _scrollView.frame.size.width, 0);
    _scrollView.contentOffset = CGPointMake(self.currentImageIndex * _scrollView.frame.size.width, 0);
    if (!_hasShowedFistView) {
        [self showFirstImage];
    }
         _indexLabel.center = CGPointMake(self.bounds.size.width * 0.5, 35);
  
 //   _saveButton.frame = CGRectMake(self.bounds.size.width-65, self.bounds.size.height - 70, 50, 50);
}

- (void)show
{
    
  
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    self.frame = window.bounds;
    [window addObserver:self forKeyPath:@"frame" options:0 context:nil];
    [window addSubview:self];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(UIView *)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        self.frame = object.bounds;
    }
}

- (void)showFirstImage
{
    //删除已经删除的cell
    NSMutableArray *viewArray = [[NSMutableArray alloc]init];
    for(id view in self.sourceImagesContainerView.subviews)
    {
        if([view isKindOfClass:[UICollectionViewCell class]])
        {
            CXXPhotoCell *cell = view;
            if(!cell.hidden)
            {
                [viewArray addObject:view];
            }
        }
    }
    UIView *sourceView = viewArray[self.currentImageIndex];
    CGRect rect = [self.sourceImagesContainerView convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    
    [self addSubview:tempView];
    
    CGRect targetTemp = [_scrollView.subviews[self.currentImageIndex] bounds];
    
    tempView.frame = rect;
    tempView.contentMode = [_scrollView.subviews[self.currentImageIndex] contentMode];
    _scrollView.hidden = YES;
    
    
    [UIView animateWithDuration:SDPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.center = self.center;
        tempView.bounds = (CGRect){CGPointZero, targetTemp.size};
    } completion:^(BOOL finished) {
        _hasShowedFistView = YES;
        [tempView removeFromSuperview];
        _scrollView.hidden = NO;
    }];
}

- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.delegate photoBrowser:self placeholderImageForIndex:index];
    }
    return nil;
}

- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if ([self.delegate respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        return [self.delegate photoBrowser:self highQualityImageURLForIndex:index];
    }
    return nil;
}

#pragma mark - scrollview代理方法

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int index = (scrollView.contentOffset.x + _scrollView.bounds.size.width * 0.5) / _scrollView.bounds.size.width;
    
    // 有过缩放的图片在拖动一定距离后清除缩放
    CGFloat margin = 150;
    CGFloat x = scrollView.contentOffset.x;
    if ((x - index * self.bounds.size.width) > margin || (x - index * self.bounds.size.width) < - margin) {
        SDBrowserImageView *imageView = _scrollView.subviews[index];
        if (imageView.isScaled) {
            [UIView animateWithDuration:0.5 animations:^{
                imageView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                [imageView eliminateScale];
            }];
        }
    }
    
    _pageControl.currentPage=index;
    self.currentImageIndex = index;
    _indexLabel.text = [NSString stringWithFormat:@"%d/%ld", index + 1, (long)self.imageCount];
    [self setupImageOfImageViewForIndex:index];
}



@end