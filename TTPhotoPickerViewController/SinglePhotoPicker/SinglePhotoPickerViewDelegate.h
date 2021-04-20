//
//  SinglePhotoPickerViewDelegate.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>
#import <PhotosUI/PhotosUI.h>
#import <PhotosUI/PHPhotoLibrary+PhotosUISupport.h>

NS_ASSUME_NONNULL_BEGIN

@interface SinglePhotoPickerViewDelegate : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate>

@property (nonatomic, copy) void (^didFinishBlock) (UIImage * originalImage);
@property (nonatomic, assign) BOOL isScale;

+ (instancetype)sharedInstance;
+ (void)destory;

@end

NS_ASSUME_NONNULL_END
