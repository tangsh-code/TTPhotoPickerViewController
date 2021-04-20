//
//  TTPhotoViewController.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/17.
//

#import <UIKit/UIKit.h>
#import "TTPHAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTPhotoViewController : UIViewController

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, strong) TTPHAsset * model;

@end

NS_ASSUME_NONNULL_END
