//
//  TTPhotoTopView.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTPhotoTopView : UIView

@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, assign) BOOL isMoreSelected;

- (void)updatePhotoNumber:(NSInteger)selectedNumber maxNumber:(NSInteger)maxNumber;

- (void)hiddenTitleAndNumber:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
