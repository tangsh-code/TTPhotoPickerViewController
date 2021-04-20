//
//  TTPhotoPageCollectionView.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/20.
//

#import "TTPhotoPageCollectionView.h"
#import "TTPhotoPageCollectionViewCell.h"

@interface TTPhotoPageCollectionView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView * collectionView;

@end

@implementation TTPhotoPageCollectionView

- (void)dealloc
{
    CheckRunWhere
}

- (UICollectionView *)collectionView
{
    if (nil == _collectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat width = 50;
        flowLayout.itemSize = CGSizeMake(width, width);
        flowLayout.minimumLineSpacing = 10;
        flowLayout.minimumInteritemSpacing = 10;
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 15, 0, 15);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(TTPhotoPageCollectionViewCell.class) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass(TTPhotoPageCollectionViewCell.class)];
    }
    
    return _collectionView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupInitData];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshShowViewUI];
}

- (void)setupInitData
{
    [self addSubview:self.collectionView];
}

- (void)refreshShowViewUI
{
    CGRect frame = self.bounds;
    self.collectionView.frame = CGRectMake(0, 15, CGRectGetWidth(frame), 50);
}

- (void)setPhotoList:(NSArray *)photoList
{
    _photoList = photoList;
    [self.collectionView reloadData];
}

#pragma mark --- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTPhotoPageCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(TTPhotoPageCollectionViewCell.class) forIndexPath:indexPath];
    TTPHAsset * model = self.photoList[indexPath.item];
    PHAsset * asset = model.asset;
    if (model.thumbnailImage) {
        cell.imageView.image = model.thumbnailImage;
    } else {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        //图片质量
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        // 同步获得图片, 只会返回1张图片
        options.synchronous = YES;
        // 是否要原图
        CGSize size = CGSizeMake(50, 50);
        // 从asset中获得图片
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (result) {
                        cell.imageView.image = result;
                    }
                });
            }];
        });
    }

    return cell;
}

#pragma mark ----- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.clickBlock) {
        self.clickBlock(self.photoList[indexPath.item]);
    }
}

@end
