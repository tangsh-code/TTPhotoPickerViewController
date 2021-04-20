//
//  TTPHAsset.h
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTPHAsset : NSObject

@property (nonatomic, strong) PHAsset * asset;
/// 是否选中图片
@property (nonatomic, assign) BOOL isSelected;
/// 是否原图
@property (nonatomic, assign) BOOL isOriginal;
/// 缩略图
@property (nonatomic, strong) UIImage * thumbnailImage;
/// 预览原图
@property (nonatomic, strong) UIImage * previewImage;
/// 数字顺序
@property (nonatomic, assign) NSInteger index;
// 图片已经选满
@property (nonatomic, assign) BOOL isFull;

@end

NS_ASSUME_NONNULL_END
