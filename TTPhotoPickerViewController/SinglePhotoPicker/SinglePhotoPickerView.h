//
//  SinglePhotoPickerView.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectResultBlock)(UIImage * pictureImage);

@interface SinglePhotoPickerView : NSObject

@property (nonatomic, strong) UIViewController * rootViewController;

// 是否编辑图片 iOS14 后不适用
@property (nonatomic, assign) BOOL allowsEditing;
// 是否压缩图片
@property (nonatomic, assign) BOOL isScale;
// 是否有相机
@property (nonatomic, assign) BOOL isCamera;

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController;

- (void)showAlertViewWithResult:(SelectResultBlock)complate;

@end

NS_ASSUME_NONNULL_END
