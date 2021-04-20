//
//  TTPhotoPageTopView.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTPhotoPageTopView : UIView

@property (nonatomic, strong) UIButton * backButton;
@property (nonatomic, assign) BOOL isMoreSelected;

- (void)updatePhotoNumber:(NSInteger)selectedNumber maxNumber:(NSInteger)maxNumber;

@end

NS_ASSUME_NONNULL_END
