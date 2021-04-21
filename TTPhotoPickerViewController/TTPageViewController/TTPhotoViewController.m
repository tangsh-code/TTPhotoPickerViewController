//
//  TTPhotoViewController.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/17.
//

#import "TTPhotoViewController.h"

#define ImageMaximumZoomScale 2.0

@interface TTPhotoViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView * scrollView;
@property (nonatomic, strong) UIImageView * previewImageView;
@property (nonatomic, assign) int32_t imageRequestID;
@property (nonatomic, copy) NSString *representedAssetIdentifier;

@end

@implementation TTPhotoViewController

- (void)dealloc
{
    CheckRunWhere
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    [self.scrollView addSubview:self.previewImageView];
    [self.view addSubview:self.scrollView];
    [self addGestureRecognizer];
}

- (void)addGestureRecognizer
{
    UITapGestureRecognizer *singleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
    UITapGestureRecognizer *doubleTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:singleTap];
    [self.view addGestureRecognizer:doubleTap];
}

- (void)setModel:(TTPHAsset *)model
{
    _model = model;
    [self updateShowUI];
}

- (void)updateShowUI
{
    PHAsset * asset = self.model.asset;
    self.representedAssetIdentifier = asset.localIdentifier;
    if (self.imageRequestID) {
        [[PHImageManager defaultManager] cancelImageRequest:self.imageRequestID];
    }
    [self.scrollView setZoomScale:1.0];
    self.previewImageView.image = nil;
    if (self.model.previewImage) {
        self.previewImageView.image = self.model.previewImage;
        [self resizeSubviews];
    } else {
        self.previewImageView.image = self.model.thumbnailImage;
        __weak typeof(self) weakSelf = self;
//        PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
//        imageRequestOptions.networkAccessAllowed = YES;
//        CGFloat screenScale = [UIScreen mainScreen].scale;
//        PHCachingImageManager *cachingImageManager = [[PHCachingImageManager alloc] init];
//        CGSize size = [UIScreen mainScreen].bounds.size;
//        [cachingImageManager requestImageForAsset:asset
//                                       targetSize:CGSizeMake(size.width * screenScale, size.height * screenScale)
//                                      contentMode:PHImageContentModeAspectFill
//                                          options:imageRequestOptions
//                                    resultHandler:^(UIImage *_Nullable result, NSDictionary *_Nullable info) {
//                                if (NO == [weakSelf.representedAssetIdentifier
//                                        isEqualToString:asset.localIdentifier])
//                                    return;
//                                if (nil == result) {
//                                    NSLog(@"未请求到图片");
//                                    return;
//                                }
//                                weakSelf.previewImageView.image = result;
//                                weakSelf.model.previewImage = result;
//                                [weakSelf resizeSubviews];
//                                    }];
//        cachingImageManager.allowsCachingHighQualityImages = NO;

        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        //图片质量
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        // 是否要原图
        CGSize size = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        // 从asset中获得图片
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (NO == [weakSelf.representedAssetIdentifier
                            isEqualToString:asset.localIdentifier])
                        return;
                    if (nil == result) {
                        NSLog(@"未请求到图片");
                        return;
                    }
                    weakSelf.previewImageView.image = result;
                    weakSelf.model.previewImage = result;
                    [weakSelf resizeSubviews];
                });
            }];
        });
    }
}

- (void)resizeSubviews {
    UIImage *image = self.previewImageView.image;
    if (image) {
        CGRect frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeight = image.size.height;
        CGFloat scrollViewWidth = self.scrollView.frame.size.width;
        CGFloat scrollViewHeight = self.scrollView.frame.size.height;
        CGPoint center = CGPointMake(scrollViewWidth / 2, scrollViewHeight / 2);

        if (imageHeight / imageWidth > scrollViewHeight / scrollViewWidth) {
            frame.size.height = floor(imageHeight / (imageWidth / scrollViewWidth));
            center.y = frame.size.height / 2;
        } else {
            CGFloat height = imageHeight / imageWidth * scrollViewWidth;
            if (height < 1 || isnan(height))
                height = scrollViewHeight;
            height = floor(height);
            frame.size.height = height;
        }

        self.previewImageView.frame = frame;
        self.previewImageView.center = center;
        self.scrollView.contentSize =
            CGSizeMake(self.view.frame.size.width, MAX(self.view.frame.size.height, self.previewImageView.frame.size.height));
        [self.scrollView scrollRectToVisible:self.view.bounds animated:NO];
        self.scrollView.alwaysBounceVertical = self.previewImageView.frame.size.height > scrollViewHeight;
        //如果图片高度按默认的最大放大比例放大后仍不能充满屏幕，最大缩放比例就改为图片显示高度和屏幕高度比例，使其放大后可以充满屏幕
        self.scrollView.maximumZoomScale = frame.size.height * ImageMaximumZoomScale < scrollViewHeight
                                               ? (scrollViewHeight / frame.size.height)
                                               : ImageMaximumZoomScale;
    }
}

- (void)setImageCenter:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.frame.size.width > scrollView.contentSize.width)
                          ? (scrollView.frame.size.width - scrollView.contentSize.width) * 0.5
                          : 0.0;
    CGFloat offsetY = (scrollView.frame.size.height > scrollView.contentSize.height)
                          ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5
                          : 0.0;
    self.previewImageView.center =
        CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)singleTap:(UITapGestureRecognizer *)sender {
//    self.singleTap();
    NSLog(@"单击-----------");
}

- (void)doubleTap:(UITapGestureRecognizer *)sender {
    if (self.model.asset.mediaType == PHAssetMediaTypeVideo && NSClassFromString(@"RCSightCapturer")) {
        return;
    }
    if (self.scrollView.zoomScale > 1.0f) {
        [self.scrollView setZoomScale:1.0 animated:YES];
    } else {
        CGPoint touchPoint = [sender locationInView:self.previewImageView];
        CGFloat newZoomScale = self.scrollView.maximumZoomScale;
        CGFloat xsize = self.view.frame.size.width / newZoomScale;
        CGFloat ysize = self.view.frame.size.height / newZoomScale;
        [self.scrollView zoomToRect:CGRectMake(touchPoint.x - xsize / 2, touchPoint.y - ysize / 2, xsize, ysize)
                           animated:YES];
    }
}

#pragma mark ---- UIScrollViewDelegate
- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.previewImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setImageCenter:scrollView];
}

#pragma mark ---- Lazy Init
- (UIScrollView *)scrollView
{
    if (nil == _scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT)];
        _scrollView.delegate = self;
        _scrollView.maximumZoomScale = ImageMaximumZoomScale;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.delaysContentTouches = NO;
    }
    
    return _scrollView;
}

- (UIImageView *)previewImageView
{
    if (nil == _previewImageView) {
        _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _previewImageView.clipsToBounds = YES;
        _previewImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _previewImageView;
}

@end
