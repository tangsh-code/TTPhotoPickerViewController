//
//  ViewController.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import "ViewController.h"
#import "SinglePhotoPickerView.h"
#import "TTPhotoPickerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)clickButtonAction:(UIButton *)sender {
    if (sender.tag == 0) {
        SinglePhotoPickerView * pickerView = [[SinglePhotoPickerView alloc] initWithRootViewController:self];
        pickerView.isCamera = YES;
        pickerView.allowsEditing = YES;
        pickerView.isScale = YES;
        [pickerView showAlertViewWithResult:^(UIImage * _Nonnull pictureImage) {
            NSLog(@"pictureImage == %@", pictureImage);
        }];
    } else if (sender.tag == 1) {
        // 请求查看相册权限 如果未设置，弹出权限提示框
        if (@available(iOS 14, *)) {
            PHAccessLevel level = PHAccessLevelReadWrite;
            [PHPhotoLibrary requestAuthorizationForAccessLevel:level handler:^(PHAuthorizationStatus status) {
                NSLog(@"status ==== %ld", (long)status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (status == PHAuthorizationStatusNotDetermined) {
                        // 请求基本不走这方法
                    } else {
                        [self gotoSelectPhotoAction];
                    }
                });
            }];
        } else {
            // Fallback on earlier versions
            [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                NSLog(@"status ==== %ld", (long)status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 未进行任何授权操作
                    if (status == PHAuthorizationStatusNotDetermined) {
                        // 请求基本不走这方法
                    } else {
                        [self gotoSelectPhotoAction];
                    }
                });
            }];
        }
    }
}

- (void)gotoSelectPhotoAction
{
    TTPhotoPickerViewController * photoPickerViewController = [[TTPhotoPickerViewController alloc] init];
//    photoPickerViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    photoPickerViewController.isMoreSelected = YES;
    photoPickerViewController.resultBlock = ^(NSArray<TTPHAsset *> * _Nonnull photoArray) {
        NSLog(@"count ==== %ld", photoArray.count);
        for (TTPHAsset * member in photoArray) {
            NSLog(@"xxxx === %@", member);
        }
    };
    
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:photoPickerViewController];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:nav animated:YES completion:nil];
}

@end
