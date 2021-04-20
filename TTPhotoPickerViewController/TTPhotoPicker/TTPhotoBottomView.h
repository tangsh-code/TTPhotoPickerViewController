//
//  TTPhotoBottomView.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^ClickBlock)(NSInteger index, BOOL isOriginalPhoto);

@interface TTPhotoBottomView : UIView

@property (nonatomic, copy) ClickBlock clickBlock;

- (void)updateBottomViewWithPhotoNumber:(NSInteger)selectPhotoNumber;

@end

NS_ASSUME_NONNULL_END
