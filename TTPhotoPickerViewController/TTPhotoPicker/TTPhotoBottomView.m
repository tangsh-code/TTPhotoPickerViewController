//
//  TTPhotoBottomView.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/16.
//

#import "TTPhotoBottomView.h"

@interface TTPhotoBottomView ()

@property (nonatomic, strong) UIButton * previewButton;
@property (nonatomic, strong) UIButton * originalButton;
@property (nonatomic, strong) UIButton * sendButton;
@property (nonatomic, assign) NSInteger photoNumber;
/// 是否原图
@property (nonatomic, assign) BOOL isOriginal;

@end

@implementation TTPhotoBottomView

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
    [self addSubview:self.previewButton];
    [self addSubview:self.originalButton];
    [self addSubview:self.sendButton];
}

- (void)refreshShowViewUI
{
    CGRect frame = self.bounds;
    self.previewButton.frame = CGRectMake(8, 0, frame.size.height, frame.size.height);
    self.originalButton.frame = CGRectMake((frame.size.width - 100)/2, (frame.size.height - 32)/2, 100, 32);
    CGFloat sendWidth = 60;
    CGFloat sendHeight = 32;
    if (self.photoNumber > 0) {
        sendWidth = 80;
    }
    self.sendButton.frame = CGRectMake(frame.size.width - sendWidth - 15, (frame.size.height - sendHeight)/2, sendWidth, sendHeight);
}

- (void)updateBottomViewWithPhotoNumber:(NSInteger)selectPhotoNumber
{
    self.photoNumber = selectPhotoNumber;
    if (selectPhotoNumber > 0) {
        self.previewButton.alpha = 1;
        [self.sendButton setTitle:[NSString stringWithFormat:@"发送(%ld)", (long)selectPhotoNumber] forState:UIControlStateNormal];
        self.sendButton.backgroundColor = kColorWithHEX(0xFC4A5B);
        self.sendButton.alpha = 1;
    } else {
        self.previewButton.alpha = 0.6;
        [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
        self.sendButton.backgroundColor = kColorWithHEX(0x424242);
        self.sendButton.alpha = 0.6;
    }
    [self setNeedsLayout];
}

- (void)clickButtonAction:(UIButton *)sender
{
    if (sender.tag == 1) {
        if (self.photoNumber == 0) {
            return;
        }
    } else if (sender.tag == 2) {
        sender.selected = !sender.selected;
        self.isOriginal = sender.selected;
    } else if (sender.tag == 3) {
        if (self.photoNumber == 0) {
            return;
        }
    }
    if (self.clickBlock) {
        self.clickBlock(sender.tag, self.isOriginal);
    }
}

- (UIButton *)previewButton
{
    if (nil == _previewButton) {
        _previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _previewButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _previewButton.tag = 1;
        [_previewButton setTitle:@"预览" forState:UIControlStateNormal];
        [_previewButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _previewButton;
}

- (UIButton *)originalButton
{
    if (nil == _originalButton) {
        _originalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _originalButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _originalButton.tag = 2;
        [_originalButton setImage:[UIImage imageNamed:@"photo_unsct"] forState:UIControlStateNormal];
        [_originalButton setImage:[UIImage imageNamed:@"photo_sct"] forState:UIControlStateSelected];
        _originalButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 5);
        _originalButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        [_originalButton setTitle:@"原图" forState:UIControlStateNormal];
        [_originalButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _originalButton;
}

- (UIButton *)sendButton
{
    if (nil == _sendButton) {
        _sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _sendButton.tag = 3;
        _sendButton.layer.cornerRadius = 3;
        _sendButton.layer.masksToBounds = YES;
        [_sendButton setTitle:@"发送" forState:UIControlStateNormal];
        [_sendButton addTarget:self action:@selector(clickButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _sendButton;
}

@end
