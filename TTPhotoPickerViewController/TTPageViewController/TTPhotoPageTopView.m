//
//  TTPhotoPageTopView.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/19.
//

#import "TTPhotoPageTopView.h"

@interface TTPhotoPageTopView ()

@property (nonatomic, strong) UIView * containerView;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * numberLabel;

@end

@implementation TTPhotoPageTopView

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
    [self refreshShowViewUI];
}

- (void)setupInitData
{
    [self.containerView addSubview:self.backButton];
    [self.containerView addSubview:self.titleLabel];
    [self.containerView addSubview:self.numberLabel];
    [self addSubview:self.containerView];
}

- (void)updateTitleNumber:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)refreshShowViewUI
{
    CGRect frame = self.bounds;
    self.containerView.frame = CGRectMake(0, frame.size.height - 44, frame.size.width, 44);
    self.backButton.frame = CGRectMake(8, 0, CGRectGetHeight(self.containerView.frame), CGRectGetHeight(self.containerView.frame));
    self.titleLabel.frame = CGRectMake((CGRectGetWidth(self.containerView.frame) - 100)/2, 12, 100, 20);
    self.numberLabel.frame = CGRectMake(CGRectGetWidth(self.containerView.frame) - 52 - 15, (CGRectGetHeight(self.containerView.frame) - 30)/2, 52, 30);
    if (self.isMoreSelected) {
        self.numberLabel.frame = CGRectMake(CGRectGetWidth(self.containerView.frame) - 80 - 15, (CGRectGetHeight(self.containerView.frame) - 30)/2, 80, 30);
    }
}

#pragma mark --- Lazy Init ---
- (UIView *)containerView
{
    if (nil == _containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    
    return _containerView;
}

- (UIButton *)backButton
{
    if (nil == _backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 44, 44);
        [_backButton setImage:[UIImage imageNamed:@"photo_btn_back"] forState:UIControlStateNormal];
    }
    
    return _backButton;
}

- (UILabel *)titleLabel
{
    if (nil == _titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.adjustsFontSizeToFitWidth = YES;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:18];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    return _titleLabel;
}

- (UILabel *)numberLabel
{
    if (nil == _numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.textColor = [UIColor whiteColor];
        _numberLabel.font = [UIFont systemFontOfSize:15];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.backgroundColor = kColorWithHEX(0xFC4A5B);
        _numberLabel.layer.cornerRadius = 3;
        _numberLabel.layer.masksToBounds = YES;
    }
    
    return _numberLabel;
}

- (void)updatePhotoNumber:(NSInteger)selectedNumber maxNumber:(NSInteger)maxNumber
{
    if (self.isMoreSelected) {
        self.numberLabel.text = [NSString stringWithFormat:@"选中(%ld/%ld)", (long)selectedNumber, (long)maxNumber];
    } else {
        self.numberLabel.text = @"选中";
    }
    if (selectedNumber == 0) {
        self.numberLabel.backgroundColor = kColorWithHEX(0x424242);
        self.numberLabel.alpha = 0.6;
    } else {
        self.numberLabel.backgroundColor = kColorWithHEX(0xFC4A5B);
        self.numberLabel.alpha = 1;
    }
}

@end
