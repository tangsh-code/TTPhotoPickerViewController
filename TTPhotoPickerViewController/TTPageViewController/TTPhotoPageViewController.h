//
//  TTPhotoPageViewController.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/19.
//

#import <UIKit/UIKit.h>
#import "TTPhotoViewController.h"

NS_ASSUME_NONNULL_BEGIN
typedef void(^BackReloadBlock)(void);

@interface TTPhotoPageViewController : UIViewController

@property (nonatomic, strong) NSArray<TTPHAsset *> * photoList;
@property (nonatomic, strong) NSMutableArray<TTPHAsset *> * selectedList;
@property (nonatomic, assign) NSInteger startIndex;
@property (nonatomic, assign) BOOL isMoreSelected;
@property (nonatomic, copy) BackReloadBlock reloadBlock;
/// 是否循环滚动
@property (nonatomic, assign) BOOL isCycle;

@end

NS_ASSUME_NONNULL_END
