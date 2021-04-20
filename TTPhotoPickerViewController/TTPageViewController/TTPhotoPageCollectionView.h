//
//  TTPhotoPageCollectionView.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/20.
//

#import <UIKit/UIKit.h>
#import "TTPHAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTPhotoPageCollectionView : UIView

@property (nonatomic, strong) NSArray<TTPHAsset *> * photoList;

@property (nonatomic, copy) ClickPHAssetBlock clickBlock;

@end

NS_ASSUME_NONNULL_END
