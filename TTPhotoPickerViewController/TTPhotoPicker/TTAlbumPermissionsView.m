//
//  TTAlbumPermissionsView.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import "TTAlbumPermissionsView.h"

@interface TTAlbumPermissionsView ()

@property (nonatomic, strong) UIView * backgroundView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * contentLabel;
@property (nonatomic, strong) UIButton * sysButton;

@end

@implementation TTAlbumPermissionsView

- (void)dealloc
{
    CheckRunWhere
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
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        edgeInsets = self.safeAreaInsets;
    } else {
        // Fallback on earlier versions
    }
    NSLog(@"self - insets - %@", NSStringFromUIEdgeInsets(edgeInsets));
    [self refreshShowViewUI];
}

- (void)setupInitData
{
    [self addSubview:self.backgroundView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.sysButton];
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
        if (status == PHAuthorizationStatusLimited) {
            self.titleLabel.text = @"无法访问相册中所有照片";
            self.contentLabel.text = @"APP只能访问相册中的部分照片，建议前往系统设置，允许APP访问「照片」中的「所有照片」";
            [self addSubview:self.photoButton];
        } else if (status == PHAuthorizationStatusDenied) {
            self.titleLabel.text = @"无法访问相册中照片";
            self.contentLabel.text = @"当前照片无访问权限，建议前往系统设置，允许APP访问「照片」中的「所有照片」";
        }
    } else {
        if (status == PHAuthorizationStatusDenied) {
            self.titleLabel.text = @"无法访问相册中照片";
            self.contentLabel.text = @"当前照片无访问权限，建议前往系统设置，允许APP访问「照片」中的「所有照片」";
        }
    }
}

- (void)refreshShowViewUI
{
    [self.backgroundView setFrame:self.bounds];
    CGRect frame = self.bounds;
    self.titleLabel.frame = CGRectMake(0, 120, frame.size.width, 20);
    self.contentLabel.frame = CGRectMake(40, CGRectGetMaxY(self.titleLabel.frame) + 15, frame.size.width - 80, 80);
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
        if (status == PHAuthorizationStatusLimited) {
            self.photoButton.frame = CGRectMake((frame.size.width - 120)/2, frame.size.height - 20 - 36, 120, 36);
            self.sysButton.frame = CGRectMake((frame.size.width - 160)/2, CGRectGetMinY(self.photoButton.frame) - 50 - 44, 160, 44);
        } else if (status == PHAuthorizationStatusDenied) {
            self.sysButton.frame = CGRectMake((frame.size.width - 160)/2, frame.size.height - 60 - 44, 160, 44);
        }
    } else {
        self.sysButton.frame = CGRectMake((frame.size.width - 160)/2, frame.size.height - 60 - 44, 160, 44);
    }
}

#pragma mark --- Button Actions

- (void)sysButtonAction:(UIButton *)sender
{
    NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if( [[UIApplication sharedApplication] canOpenURL:url] ) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL  success) {
        }];
    }
}

#pragma mark --- Lazy init
- (UIView *)backgroundView
{
    if (nil == _backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _backgroundView;
}

- (UILabel *)titleLabel
{
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:20];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (UILabel *)contentLabel
{
    if (nil == _contentLabel) {
        _contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textAlignment = NSTextAlignmentCenter;
        _contentLabel.numberOfLines = 0;
    }
    
    return _contentLabel;
}

- (UIButton *)sysButton
{
    if (nil == _sysButton) {
        _sysButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sysButton.frame = CGRectZero;
        _sysButton.layer.cornerRadius = 5;
        _sysButton.layer.masksToBounds = YES;
        _sysButton.backgroundColor = kColorWithHEX(0xFC4A5B);
        [_sysButton setTitle:@"前往系统设置" forState:UIControlStateNormal];
        [_sysButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _sysButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sysButton addTarget:self action:@selector(sysButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sysButton;
}

- (UIButton *)photoButton
{
    if (nil == _photoButton) {
        _photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _photoButton.frame = CGRectZero;
        [_photoButton setTitle:@"继续访问部分照片" forState:UIControlStateNormal];
        [_photoButton setTitleColor:kColorWithHEX(0xFC4A5B) forState:UIControlStateNormal];
        _photoButton.titleLabel.font = [UIFont systemFontOfSize:12];
    }
    
    return _photoButton;
}

@end
