//
//  TTPhotoPageBottomView.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/19.
//

#import "TTPhotoPageBottomView.h"

@interface TTPhotoPageBottomView () 

@property (nonatomic, strong) UIView * containerView;

@property (nonatomic, strong) UIView * statusView;
@property (nonatomic, strong) UIImageView * statusImageView;
@property (nonatomic, strong) UIButton * statusButton;
@property (nonatomic, strong) UILabel * numberLabel;

@end

@implementation TTPhotoPageBottomView

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
//    [self.containerView addSubview:self.backButton];
//    [self.containerView addSubview:self.titleLabel];
//    [self.containerView addSubview:self.numberLabel];
    
    [self.statusView addSubview:self.statusImageView];
    [self.statusView addSubview:self.numberLabel];
    [self.statusView addSubview:self.statusButton];
    [self.containerView addSubview:self.statusView];
    
    [self addSubview:self.containerView];
}

- (void)refreshShowViewUI
{
    CGRect frame = self.bounds;
    self.containerView.frame = CGRectMake(0, 0, frame.size.width, 30);
    self.statusView.frame = CGRectMake(frame.size.width - 38, 0, 30, 30);
    self.statusImageView.frame = CGRectMake(0, 0, 22, 22);
    self.statusImageView.center = CGPointMake(CGRectGetWidth(self.statusView.frame)/2, CGRectGetHeight(self.statusView.frame)/2);
    self.statusButton.frame = CGRectMake(0, 0, CGRectGetWidth(self.statusView.frame), CGRectGetHeight(self.statusView.frame));
    self.numberLabel.frame = CGRectMake(0, 0, CGRectGetWidth(self.statusView.frame), CGRectGetHeight(self.statusView.frame));
}

- (void)setModel:(TTPHAsset *)model
{
    _model = model;
    [self reloadShowUI];
}

- (void)updateShowUI
{
    [self reloadShowUI];
}

- (void)reloadShowUI
{
    if (self.model.isSelected) {
        self.statusImageView.image = [UIImage imageNamed:@"photo_sct"];
        if (self.model.index > 0) {
            self.numberLabel.text = [NSString stringWithFormat:@"%ld", (long)self.model.index];
        }
    } else {
        self.statusImageView.image = [UIImage imageNamed:@"photo_full_unsct"];
        self.numberLabel.text = @"";
    }
}

- (void)statusButtonAction:(UIButton *)sender
{
    if (self.clickBlock) {
        self.clickBlock(self.model);
    }
}

#pragma mark --- Lazy Init ---
- (UIView *)containerView
{
    if (nil == _containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        _containerView.backgroundColor = [UIColor clearColor];
    }
    
    return _containerView;
}

- (UIView *)statusView
{
    if (nil == _statusView) {
        _statusView = [[UIView alloc] initWithFrame:CGRectZero];
        _statusView.backgroundColor = [UIColor clearColor];
    }
    
    return _statusView;
}

- (UIImageView *)statusImageView
{
    if (nil == _statusImageView) {
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _statusImageView.image = [UIImage imageNamed:@"photo_full_unsct"];
    }
    
    return _statusImageView;
}

- (UIButton *)statusButton
{
    if (nil == _statusButton) {
        _statusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _statusButton.frame = CGRectZero;
        [_statusButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _statusButton;
}

- (UILabel *)numberLabel
{
    if (nil == _numberLabel) {
        _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _numberLabel.textAlignment = NSTextAlignmentCenter;
        _numberLabel.font = [UIFont systemFontOfSize:12];
        _numberLabel.textColor = [UIColor whiteColor];
    }
    
    return _numberLabel;
}


@end
