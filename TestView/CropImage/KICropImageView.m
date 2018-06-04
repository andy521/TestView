//
//  KICropImageView.m
//  Kitalker
//
//  Created by 杨 烽 on 12-8-9.
//
//

#import "KICropImageView.h"
#define kScreenHeight [UIScreen mainScreen].bounds.size.height//获取屏幕高度
#define kScreenWidth [UIScreen mainScreen].bounds.size.width//获取屏幕宽度
@implementation KICropImageView

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [[self scrollView] setFrame:self.bounds];
    [[self maskView] setFrame:self.bounds];
    
    if (CGSizeEqualToSize(_cropSize, CGSizeZero)) {
        
        
//        修改以后使用的代码
        [self setCropSize:CGSizeMake(kScreenWidth*2, kScreenWidth*2)];
        
//        [self setCropSize:CGSizeMake(100, 100)];
        
    }
}

- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        [_scrollView setDelegate:self];
        [_scrollView setBounces:NO];
        [_scrollView setShowsHorizontalScrollIndicator:NO];
        [_scrollView setShowsVerticalScrollIndicator:NO];
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIImageView *)imageView {
    if (_imageView == nil) {
        _imageView = [[UIImageView alloc] init];
        [[self scrollView] addSubview:_imageView];
    }
    return _imageView;
}

- (KICropImageMaskView *)maskView {
    if (_maskView == nil) {
        _maskView = [[KICropImageMaskView alloc] init];
        [_maskView setBackgroundColor:[UIColor clearColor]];
        [_maskView setUserInteractionEnabled:NO];
        [self addSubview:_maskView];
        [self bringSubviewToFront:_maskView];
    }
    return _maskView;
}

- (void)setImage:(UIImage *)image {
    if (image != _image) {
        [_image release];
        _image = nil;
        _image = [image retain];
    }
    [[self imageView] setImage:_image];
    
    [self updateZoomScale];
}

- (void)updateZoomScale {
    CGFloat width = _image.size.width;
    CGFloat height = _image.size.height;
    
    [[self imageView] setFrame:CGRectMake(0, 0, width, height)];
    
    CGFloat xScale = _cropSize.width / width;
    CGFloat yScale = _cropSize.height / height;
    
    CGFloat min = MAX(xScale, yScale);
    CGFloat max = 1.0;
    
//徐用的时候把它注释了
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//        max = 1.0 / [[UIScreen mainScreen] scale];
//    }
    
    
//    //控制图片的大小
//    
//    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
//        max = 1.0 / [[UIScreen mainScreen] scale];
//    }
    
    
    if (min > max) {
        min = max;
    }
    
    [[self scrollView] setMinimumZoomScale:min];
    [[self scrollView] setMaximumZoomScale:max + 5.0f];
    
    [[self scrollView] setZoomScale:min animated:YES];
}

- (void)setCropSize:(CGSize)size {
    _cropSize = size;
    [self updateZoomScale];
    
    CGFloat width = _cropSize.width;
    CGFloat height = _cropSize.height;
    
    CGFloat x = (CGRectGetWidth(self.bounds) - width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - height) / 2;

    [[self maskView] setCropSize:_cropSize];
    
    CGFloat top = y;
    CGFloat left = x;
    CGFloat right = CGRectGetWidth(self.bounds)- width - x;
    CGFloat bottom = CGRectGetHeight(self.bounds)- height - y;
    _imageInset = UIEdgeInsetsMake(top, left, bottom, right);
    [[self scrollView] setContentInset:_imageInset];
    
    [[self scrollView] setContentOffset:CGPointMake(0, 0)];
}

- (UIImage *)cropImage {
    
  
    
    CGFloat zoomScale = [self scrollView].zoomScale;
    
    CGFloat offsetX = [self scrollView].contentOffset.x;
    CGFloat offsetY = [self scrollView].contentOffset.y;
    CGFloat aX = offsetX>=0 ? offsetX+_imageInset.left : (_imageInset.left - ABS(offsetX));
    CGFloat aY = offsetY>=0 ? offsetY+_imageInset.top : (_imageInset.top - ABS(offsetY));
    
    aX = aX / zoomScale;
    aY = aY / zoomScale;
    
//    CGFloat aWidth =  MAX(_cropSize.width / zoomScale, _cropSize.width);
//    CGFloat aHeight = MAX(_cropSize.height / zoomScale, _cropSize.height);
    
    
//  徐用的时候的代码，把上面的代码注释了
    CGFloat aWidth = MIN(_cropSize.width / zoomScale, _cropSize.width);
    CGFloat aHeight = MIN(_cropSize.height / zoomScale, _cropSize.height); //添加
    if (zoomScale < 1) { aWidth = MAX(_cropSize.width / zoomScale, _cropSize.width); aHeight = MAX(_cropSize.height / zoomScale, _cropSize.height); }
    
#ifdef DEBUG
    NSLog(@"%f--%f--%f--%f", aX, aY, aWidth, aHeight);
#endif
    
    UIImage *image = [_image cropImageWithX:aX y:aY width:aWidth height:aHeight];
    
//    image = [image resizeToWidth:_cropSize.width height:_cropSize.height];

    return image;
}

#pragma UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self imageView];
}

- (void)dealloc {
    [_scrollView release];
    _scrollView = nil;
    [_imageView release];
    _imageView = nil;
    [_maskView release];
    _maskView = nil;
    [_image release];
    _image = nil;
    [super dealloc];
}
@end

#pragma KISnipImageMaskView

#define kMaskViewBorderWidth 3.5f
//徐用的时候四个都用，上面的宽度为3.5f
#define kBorderWithJiao  7.0f
#define kminiWith  15.0f
#define kBrodWith 20
@implementation KICropImageMaskView

- (void)setCropSize:(CGSize)size {
    CGFloat x = (CGRectGetWidth(self.bounds) - size.width) / 2;
    CGFloat y = (CGRectGetHeight(self.bounds) - size.height) / 2;
    _cropRect = CGRectMake(x, y, size.width, size.height);
    
    [self setNeedsDisplay];
}

- (CGSize)cropSize {
    return _cropRect.size;
}

- (void)drawRect:(CGRect)rect {
    
    //模糊效果
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
   CGContextSetRGBFillColor(ctx, 1, 1, 1, .6);
 //    CGContextSetStrokeColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextFillRect(ctx, self.bounds);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, _cropRect, kMaskViewBorderWidth);
    
//    CGContextClearRect(ctx, _cropRect);

    
    
    
    //徐用下面的代码
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, _cropRect, kMaskViewBorderWidth);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    
    //外面的那个对话框
    CGContextStrokeRectWithWidth(ctx, CGRectMake(_cropRect.origin.x, _cropRect.origin.y, kBrodWith, kBrodWith), kBorderWithJiao);
//    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, CGRectMake(_cropRect.size.width-kminiWith
                                                 , _cropRect.origin.y, kBrodWith, kBrodWith), kBorderWithJiao);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, CGRectMake(_cropRect.size.width-kminiWith
                                                 ,  _cropRect.size.height+_cropRect.origin.y-kBrodWith, kBrodWith, kBrodWith), kBorderWithJiao);
    
    CGContextSetStrokeColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextStrokeRectWithWidth(ctx, CGRectMake(_cropRect.origin.x
                                                 , _cropRect.size.height+_cropRect.origin.y-kBrodWith, kBrodWith, kBrodWith), kBorderWithJiao);
    CGContextClearRect(ctx, _cropRect);
    
}
@end
