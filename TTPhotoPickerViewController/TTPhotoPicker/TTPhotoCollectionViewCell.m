//
//  TTPhotoCollectionViewCell.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import "TTPhotoCollectionViewCell.h"

@interface TTPhotoCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *addImageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *markView;
@property (weak, nonatomic) IBOutlet UIView *statusContainerView;
@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

@end

@implementation TTPhotoCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor yellowColor];
}

- (void)setModel:(TTPHAsset *)model
{
    _model = model;
    [self updateShowUI];
}

- (void)updateShowUI
{
    PHAsset * asset = self.model.asset;
    if (asset == nil) {
        self.addImageView.hidden = NO;
        self.imageView.hidden = YES;
        self.statusContainerView.hidden = YES;
        self.markView.hidden = YES;
        return;
    }
    self.addImageView.hidden = YES;
    self.imageView.hidden = NO;
    self.statusContainerView.hidden = NO;
    // 状态显示
    self.numberLabel.text = @"";
    if (self.model.isSelected) {
        self.statusImageView.image = [UIImage imageNamed:@"photo_sct"];
        if (self.model.index > 0) {
            self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)self.model.index];
        }
    } else {
        self.statusImageView.image = [UIImage imageNamed:@"photo_unsct"];
    }
    
    // 蒙版显示
    self.markView.hidden = !self.model.isFull;
    if (self.model.isFull) {
        if (self.model.index > 0) {
            self.markView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        } else {
            self.markView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.8];
        }
    }
    
    // 图片显示
    if (self.model.thumbnailImage) {
        self.imageView.image = self.model.thumbnailImage;
        return;
    }
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode = PHImageRequestOptionsResizeModeFast;
    //图片质量
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    // 同步获得图片, 只会返回1张图片
    options.synchronous = YES;
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - 4);
    // 是否要原图
    CGSize size = self.model.isOriginal ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeMake(width, width);
    // 从asset中获得图片
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (result) {
                    weakSelf.model.thumbnailImage = result;
                    weakSelf.imageView.image = result;
                }
            });
        }];
    });
}

@end
