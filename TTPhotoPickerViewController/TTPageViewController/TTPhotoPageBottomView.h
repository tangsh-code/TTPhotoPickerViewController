//
//  TTPhotoPageBottomView.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/19.
//

#import <UIKit/UIKit.h>
#import "TTPHAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTPhotoPageBottomView : UIView

@property (nonatomic, strong) TTPHAsset * model;

@property (nonatomic, copy) ClickPHAssetBlock clickBlock;

- (void)updateShowUI;

@end

NS_ASSUME_NONNULL_END
