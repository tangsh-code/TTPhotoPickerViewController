//
//  TTPhotoCollectionViewCell.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import <UIKit/UIKit.h>
#import "TTPHAsset.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) TTPHAsset * model;
@property (weak, nonatomic) IBOutlet UIButton *statusButton;

@end

NS_ASSUME_NONNULL_END
