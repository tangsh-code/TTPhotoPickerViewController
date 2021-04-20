//
//  SinglePhotoPickerViewDelegate.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import "SinglePhotoPickerViewDelegate.h"

static SinglePhotoPickerViewDelegate * instance = nil;

@implementation SinglePhotoPickerViewDelegate

- (void)dealloc
{
    NSLog(@"dealloc");
}

+ (instancetype)sharedInstance {
    if (instance == nil) {
         instance = [[self alloc] init];
    }
    return instance;
}

+ (void)destory {
    instance = nil;
}

#pragma mark ---- PHPickerViewControllerDelegate
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results
API_AVAILABLE(ios(14)) API_AVAILABLE(ios(14)){
    [picker dismissViewControllerAnimated:YES completion:nil];
    if (results.count == 1) {
        // 单张
        NSItemProvider * provider = results.firstObject.itemProvider;
        if (provider) {
            BOOL isImage = [provider canLoadObjectOfClass:[UIImage class]];
            if (isImage) {
                [provider loadObjectOfClass:[UIImage class] completionHandler:^(__kindof UIImage * image, NSError * _Nullable error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 主线程 图片
                        UIImage * orginalImage = image;
                        if (self.isScale) {
                            orginalImage = [self imageByScalingToMaxSize:image];
                        }
                        if ([SinglePhotoPickerViewDelegate sharedInstance].didFinishBlock) {
                            [SinglePhotoPickerViewDelegate sharedInstance].didFinishBlock(orginalImage);
                        }
                        [SinglePhotoPickerViewDelegate destory];
                    });
                }];
            }
        }
    }
}

#pragma mark ----- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    if ([info[UIImagePickerControllerMediaType] isEqualToString:@"public.image"]) {
        UIImage * orginalImage = [self fixOrientation:[info valueForKey:UIImagePickerControllerOriginalImage]];
        /// 如果编辑 取编辑后的图片
        if (picker.allowsEditing) {
            orginalImage = info[UIImagePickerControllerEditedImage];
        }
        // 压缩图片
        if (self.isScale) {
            orginalImage = [self imageByScalingToMaxSize:orginalImage];
        }
        
        if ([SinglePhotoPickerViewDelegate sharedInstance].didFinishBlock) {
            [SinglePhotoPickerViewDelegate sharedInstance].didFinishBlock(orginalImage);
        }
    }
    [SinglePhotoPickerViewDelegate destory];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark image scale utility 图片压缩
- (UIImage *)imageByScalingToMaxSize:(UIImage *)sourceImage
{
    if (sourceImage.size.width < kSCREEN_WIDTH) return sourceImage;
    CGFloat btWidth = 0.0f;
    CGFloat btHeight = 0.0f;
    if (sourceImage.size.width > sourceImage.size.height) {
        btHeight = kSCREEN_WIDTH;
        btWidth = sourceImage.size.width * (kSCREEN_WIDTH / sourceImage.size.height);
    } else {
        btWidth = kSCREEN_WIDTH;
        btHeight = sourceImage.size.height * (kSCREEN_WIDTH / sourceImage.size.width);
    }
    CGSize targetSize = CGSizeMake(btWidth, btHeight);
    return [self imageByScalingAndCroppingForSourceImage:sourceImage targetSize:targetSize];
}

- (UIImage *)imageByScalingAndCroppingForSourceImage:(UIImage *)sourceImage targetSize:(CGSize)targetSize
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = targetSize.width;
    CGFloat targetHeight = targetSize.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0,0.0);
    if (CGSizeEqualToSize(imageSize, targetSize) == NO)
    {
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        
        if (widthFactor > heightFactor)
            scaleFactor = widthFactor; // scale to fit height
        else
            scaleFactor = heightFactor; // scale to fit width
        scaledWidth  = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        
        // center the image
        if (widthFactor > heightFactor)
        {
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }
        else
            if (widthFactor < heightFactor)
            {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
    }
    UIGraphicsBeginImageContext(targetSize); // this will crop
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width  = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    
    [sourceImage drawInRect:thumbnailRect];
    
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil) NSLog(@"could not scale image");
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)fixOrientation:(UIImage *)aImage {
  
// No-op if the orientation is already correct
if (aImage.imageOrientation == UIImageOrientationUp)
    return aImage;
  
// We need to calculate the proper transformation to make the image upright.
// We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
CGAffineTransform transform = CGAffineTransformIdentity;
  
switch (aImage.imageOrientation) {
    case UIImageOrientationDown:
    case UIImageOrientationDownMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
        transform = CGAffineTransformRotate(transform, M_PI);
        break;
          
    case UIImageOrientationLeft:
    case UIImageOrientationLeftMirrored:
        transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
        transform = CGAffineTransformRotate(transform, M_PI_2);
        break;
          
    case UIImageOrientationRight:
    case UIImageOrientationRightMirrored:
        transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
        transform = CGAffineTransformRotate(transform, -M_PI_2);
        break;
    default:
        break;
}
    switch (aImage.imageOrientation) {
           case UIImageOrientationUpMirrored:
           case UIImageOrientationDownMirrored:
               transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
               transform = CGAffineTransformScale(transform, -1, 1);
               break;
                 
           case UIImageOrientationLeftMirrored:
           case UIImageOrientationRightMirrored:
               transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
               transform = CGAffineTransformScale(transform, -1, 1);
               break;
           default:
               break;
       }
         
       // Now we draw the underlying CGImage into a new context, applying the transform
       // calculated above.
       CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                                CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                                CGImageGetColorSpace(aImage.CGImage),
                                                CGImageGetBitmapInfo(aImage.CGImage));
       CGContextConcatCTM(ctx, transform);
       switch (aImage.imageOrientation) {
           case UIImageOrientationLeft:
           case UIImageOrientationLeftMirrored:
           case UIImageOrientationRight:
           case UIImageOrientationRightMirrored:
               // Grr...
               CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
               break;
                 
           default:
               CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
           break;
               
       }
    // And now we just create a new UIImage from the drawing context
        CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
        UIImage *img = [UIImage imageWithCGImage:cgimg];
        CGContextRelease(ctx);
        CGImageRelease(cgimg);
        return img;
}

@end
