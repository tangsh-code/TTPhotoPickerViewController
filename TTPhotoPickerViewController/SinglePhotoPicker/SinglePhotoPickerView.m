//
//  SinglePhotoPickerView.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import "SinglePhotoPickerView.h"
#import "SinglePhotoPickerViewDelegate.h"

@interface SinglePhotoPickerView ()

@property (nonatomic, copy) SelectResultBlock resultBlock;

@end

@implementation SinglePhotoPickerView

- (void)dealloc
{
    NSLog(@"dealloc");
}

- (UIViewController *)rootViewController
{
    if (nil == _rootViewController) {
        _rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    }
    
    return _rootViewController;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super init];
    if (self) {
        _rootViewController = rootViewController;
    }
    
    return self;
}

- (void)showAlertViewWithResult:(SelectResultBlock)complate;
{
    _resultBlock = complate;
    __weak typeof(self) weakSelf = self;
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction * camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (NO == [self judgeCameraAuthStatus]) {
            return ;
        }
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = self.allowsEditing;
        imagePicker.delegate = [SinglePhotoPickerViewDelegate sharedInstance];
        [SinglePhotoPickerViewDelegate sharedInstance].isScale = self.isScale;
        [SinglePhotoPickerViewDelegate sharedInstance].didFinishBlock = [self.resultBlock copy];
        [self.rootViewController presentViewController:imagePicker animated:YES completion:nil];
    }];
    UIAlertAction * library = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (NO == [self judgeLibraryAuthStatus]) {
            return;
        }
        [weakSelf showAlertViewController];
    }];
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    if (self.isCamera) {
        [alertController addAction:camera];
    }
    [alertController addAction:library];
    [alertController addAction:cancel];
    [self.rootViewController presentViewController:alertController animated:YES completion:nil];
}

- (void)showAlertViewController
{
    if (@available(iOS 14, *)) {
        PHPickerConfiguration * configuration = [[PHPickerConfiguration alloc] init];
        configuration.preferredAssetRepresentationMode = PHPickerConfigurationAssetRepresentationModeCompatible;
        // 限定选取一张 或者 多张
        configuration.selectionLimit = 1;
        // 限定类型 -- 照片
        PHPickerFilter *filter = [PHPickerFilter imagesFilter];
        configuration.filter = filter;
        PHPickerViewController * pickerViewController = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        pickerViewController.delegate = [SinglePhotoPickerViewDelegate sharedInstance];
        [SinglePhotoPickerViewDelegate sharedInstance].isScale = self.isScale;
        [SinglePhotoPickerViewDelegate sharedInstance].didFinishBlock = [self.resultBlock copy];
        [self.rootViewController presentViewController:pickerViewController animated:YES completion:nil];
    } else {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = self.allowsEditing;
        imagePicker.delegate = [SinglePhotoPickerViewDelegate sharedInstance];
        [SinglePhotoPickerViewDelegate sharedInstance].isScale = self.isScale;
        [SinglePhotoPickerViewDelegate sharedInstance].didFinishBlock = [self.resultBlock copy];
        [self.rootViewController presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (BOOL)isSimuLator
{
    if (TARGET_IPHONE_SIMULATOR == 1 && TARGET_OS_IPHONE == 1) {
        //模拟器
        return YES;
    }else{
        //真机
        return NO;
    }
}

- (BOOL)judgeCameraAuthStatus
{
    if ([self isSimuLator]) {
        NSLog(@"模拟器没摄像头权限");
        return NO;
    }
    __weak typeof(self) weakSelf = self;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusNotDetermined) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                // 真机
                UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.allowsEditing = self.allowsEditing;
                imagePicker.delegate = [SinglePhotoPickerViewDelegate sharedInstance];
                [SinglePhotoPickerViewDelegate sharedInstance].isScale = weakSelf.isScale;
                [SinglePhotoPickerViewDelegate sharedInstance].didFinishBlock = [weakSelf.resultBlock copy];
                [weakSelf.rootViewController presentViewController:imagePicker animated:YES completion:nil];
            }
        }];
        return NO;
    }
    if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"权限提示" message:@"您尚未开启相机权限，请在\"设置 - 隐私 - 相机\"选项中打开，是否现在跳转设置界面开启权限？" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication] canOpenURL:url] ) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL  success) {

                }];
            }
        }]];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (BOOL)judgeLibraryAuthStatus
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
        if (status == PHAuthorizationStatusNotDetermined) {
            [PHPhotoLibrary requestAuthorizationForAccessLevel:level handler:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [self showAlertViewController];
                } else if (status == PHAuthorizationStatusLimited) {
                    //待优化
                }
            }];
            return NO;
        } else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"权限提示" message:@"您尚未开启相册权限，请在\"设置 - 隐私 - 照片\"选项中打开， 是否现在跳转设置界面开启权限？" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if( [[UIApplication sharedApplication] canOpenURL:url] ) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL  success) {

                    }];
                }
            }]];
            [self.rootViewController presentViewController:alertController animated:YES completion:nil];
            return NO;
        }
        return YES;
    } else {
        if (status == PHAuthorizationStatusNotDetermined) {
            __weak typeof(self) weakSelf = self;
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                if (status == PHAuthorizationStatusAuthorized) {
                    [weakSelf showAlertViewController];
                }
            }];
            return NO;
        } else if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"权限提示" message:@"您尚未开启相册权限，请在\"设置 - 隐私 - 照片\"选项中打开, 是否现在跳转设置界面开启权限？" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }]];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                NSURL * url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if( [[UIApplication sharedApplication] canOpenURL:url] ) {
                    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL  success) {

                    }];
                }
            }]];
            [self.rootViewController presentViewController:alertController animated:YES completion:nil];
            return NO;
        }
        return YES;
    }
}

@end
