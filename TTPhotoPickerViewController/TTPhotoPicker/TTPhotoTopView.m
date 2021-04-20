//
//  TTPhotoTopView.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/16.
//

#import "TTPhotoTopView.h"

@interface TTPhotoTopView ()

@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UILabel * numberLabel;

@end

@implementation TTPhotoTopView

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
    [self addSubview:self.backButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.numberLabel];
}

- (void)hiddenTitleAndNumber:(BOOL)isHidden
{
    self.titleLabel.hidden = isHidden;
    self.numberLabel.hidden = isHidden;
}

- (void)refreshShowViewUI
{
    CGRect frame = self.bounds;
    self.backButton.frame = CGRectMake(8, 0, frame.size.height, frame.size.height);
    self.titleLabel.frame = CGRectMake((frame.size.width - 100)/2, 12, 100, 20);
    self.numberLabel.frame = CGRectMake(frame.size.width - 52 - 15, (frame.size.height - 30)/2, 52, 30);
    if (self.isMoreSelected) {
        self.numberLabel.frame = CGRectMake(frame.size.width - 80 - 15, (frame.size.height - 30)/2, 80, 30);
    }
}

#pragma mark --- Lazy Init ---
- (UIButton *)backButton
{
    if (nil == _backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.frame = CGRectMake(0, 0, 44, 44);
        [_backButton setImage:[UIImage imageNamed:@"photo_btn_close"] forState:UIControlStateNormal];
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
        _titleLabel.text = @"所有照片";
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
