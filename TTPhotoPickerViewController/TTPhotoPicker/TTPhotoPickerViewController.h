//
//  TTPhotoPickerViewController.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import <UIKit/UIKit.h>
#import "TTAlbumPermissionsView.h"
#import "TTPHAsset.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SelectPhotoBlock)(NSArray<TTPHAsset *> * photoArray);

@interface TTPhotoPickerViewController : UIViewController

/// 照片多选
@property (nonatomic, assign) BOOL isMoreSelected;

@property (nonatomic, copy) SelectPhotoBlock resultBlock;

@end

NS_ASSUME_NONNULL_END
