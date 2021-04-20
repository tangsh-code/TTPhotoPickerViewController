//
//  TTPhotoPickerViewController.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/15.
//

#import "TTPhotoPickerViewController.h"
#import "TTPhotoPageViewController.h"
#import "TTPhotoCollectionViewCell.h"
#import "TTPhotoTopView.h"
#import "TTPhotoBottomView.h"

@interface TTPhotoPickerViewController () <UICollectionViewDataSource, UICollectionViewDelegate, PHPhotoLibraryChangeObserver>

@property (nonatomic, strong) TTPhotoTopView * topView;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) TTPhotoBottomView * bottomView;
@property (nonatomic, strong) TTAlbumPermissionsView * permissionsView;
@property (nonatomic, strong) NSMutableArray<TTPHAsset *> * photoList;
@property (nonatomic, strong) NSMutableArray<TTPHAsset *> * selectedList;
@property (nonatomic, assign) BOOL isLimit;
/// 是否原图
@property (nonatomic, assign) BOOL isOriginal;
/// 是否选满图片
@property (nonatomic, assign) BOOL isFull;

@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation TTPhotoPickerViewController

- (void)dealloc
{
    CheckRunWhere
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blackColor];
    self.photoList = [NSMutableArray array];
    self.selectedList = [NSMutableArray array];
    [self setupBaseUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setupBaseUI
{
    __weak typeof(self) weakSelf = self;
    self.topView.isMoreSelected = self.isMoreSelected;
    [self.topView hiddenTitleAndNumber:NO];
    [self.topView.backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.bottomView.clickBlock = ^(NSInteger index, BOOL isOriginalPhoto) {
        weakSelf.isOriginal = isOriginalPhoto;
        NSLog(@"-----------------------");
        if (index == 1) {
            NSLog(@"预览");
        } else if (index == 2) {
            NSLog(@"原图---------%d", weakSelf.isOriginal);
            for (TTPHAsset * member in weakSelf.selectedList) {
                member.isOriginal = weakSelf.isOriginal;
            }
        } else if (index == 3) {
            NSLog(@"发送");
            if (weakSelf.resultBlock) {
                weakSelf.resultBlock(weakSelf.selectedList);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
        }
    };
    [self.view addSubview:self.topView];
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.bottomView];
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (@available(iOS 14, *)) {
        PHAccessLevel level = PHAccessLevelReadWrite;
        status = [PHPhotoLibrary authorizationStatusForAccessLevel:level];
        if (status == PHAuthorizationStatusLimited) {
            [self.topView hiddenTitleAndNumber:YES];
            [self.permissionsView.photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.permissionsView];
            self.isLimit = YES;
            [self loadPhotoData];
        }
    }
    if (status == PHAuthorizationStatusDenied) {
        [self.topView hiddenTitleAndNumber:YES];
        [self.permissionsView.photoButton addTarget:self action:@selector(photoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.permissionsView];
    }
    if (status == PHAuthorizationStatusAuthorized) {
        [self loadPhotoData];
    }
    [self updateNumberLabel];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    [self refreshShowViewUI];
}

- (void)refreshShowViewUI
{
    CGRect frame = self.view.frame;
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    if (@available(iOS 11.0, *)) {
        edgeInsets = self.view.safeAreaInsets;
    } else {
        // Fallback on earlier versions
    }
//    NSLog(@"self.view - insets - %@", NSStringFromUIEdgeInsets(edgeInsets));
    self.topView.frame = CGRectMake(0, edgeInsets.top, frame.size.width, 44);
    self.bottomView.frame = CGRectMake(0, frame.size.height - edgeInsets.bottom - 50, frame.size.width, 50);
    self.collectionView.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), frame.size.width, frame.size.height - CGRectGetMaxY(self.topView.frame) - edgeInsets.bottom - CGRectGetHeight(self.bottomView.frame));
    self.permissionsView.frame = CGRectMake(0, CGRectGetMaxY(self.topView.frame), frame.size.width, frame.size.height - CGRectGetMaxY(self.topView.frame) - edgeInsets.bottom);
}

- (void)loadPhotoData
{
    NSLog(@"获取照片库照片数据");
    // Prevent limited photos access alert 设为NO 请求图片会弹出权限提示框 YES 不弹出
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //异步线程
        //获取可访问的图片配置选项
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        //根据图片的创建时间升序排序返回
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        //获取类型为image的资源
        PHFetchResult<PHAsset *> * result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
        NSLog(@"result - count = %ld", result.count);
        [self.photoList removeAllObjects];
         //遍历出每个PHAsset资源对象
        __weak typeof(self) weakSelf = self;
        [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            TTPHAsset * asset = [[TTPHAsset alloc] init];
            asset.asset = obj;
            [weakSelf.photoList addObject:asset];
        }];
        if (self.isLimit) {
            TTPHAsset * last = [[TTPHAsset alloc] init];
            [self.photoList addObject:last];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //主线程
            [self.collectionView reloadData];
        });
    });
}

- (void)updateNumberLabel
{
    NSLog(@"选中图片数量------%ld", self.selectedList.count);
    [self.topView updatePhotoNumber:self.selectedList.count maxNumber:kImageMaxNumber];
    [self.bottomView updateBottomViewWithPhotoNumber:self.selectedList.count];
}

#pragma mark ---- Button Actions
- (void)backButtonAction:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)photoButtonAction:(UIButton *)sender
{
    [self.permissionsView removeFromSuperview];
    [self.topView hiddenTitleAndNumber:NO];
}

#pragma mark --- UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photoList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(TTPhotoCollectionViewCell.class) forIndexPath:indexPath];
    TTPHAsset * model = self.photoList[indexPath.item];
    model.isFull = self.isFull;
    cell.model = model;
    cell.statusButton.tag = indexPath.item;
    [cell.statusButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (void)statusButtonAction:(UIButton *)sender
{
    NSLog(@"选择图片");
    TTPHAsset * model = self.photoList[sender.tag];
    if (self.isMoreSelected) {
        // 多选
        model.isSelected = !model.isSelected;
        if ([self.selectedList containsObject:model]) {
            [self.selectedList removeObject:model];
        } else {
            if (self.selectedList.count >= kImageMaxNumber) {
                model.isSelected = !model.isSelected;
                [self showFullAlertView];
                return;
            }
            [self.selectedList addObject:model];
        }
        // 判断是否图片选满
        self.isFull = [self judgeSelectFullNumberPhoto];
        // 处理图片顺序标识
        model.index = 0;
        for (NSInteger index = 0; index < self.selectedList.count; ++index) {
            TTPHAsset * member = self.selectedList[index];
            member.index = index + 1;
        }
        [self.collectionView reloadData];
    } else {
        // 单选图片逻辑处理
        for (TTPHAsset * member in self.photoList) {
            member.isSelected = NO;
        }
        model.isSelected = YES;
        [self.selectedList removeAllObjects];
        [self.selectedList addObject:model];
        [self.collectionView reloadData];
    }
    [self updateNumberLabel];
}

- (BOOL)judgeSelectFullNumberPhoto
{
    if (self.selectedList.count == kImageMaxNumber) {
        return YES;
    }
    return NO;
}

/// 弹出选满照片提示框
- (void)showFullAlertView
{
    NSLog(@"图片已选满,最多选择9张照片");
}

#pragma mark --- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    TTPHAsset * model = self.photoList[indexPath.item];
    NSLog(@"size === %@", model.thumbnailImage);
    if (model.asset == nil) {
        NSLog(@"添加图片");
        if (@available(iOS 14, *)) {
            PHPhotoLibrary * photoLibrary = [PHPhotoLibrary sharedPhotoLibrary];
            [photoLibrary registerChangeObserver:self];
            PHPickerConfiguration * configuration = [[PHPickerConfiguration alloc] initWithPhotoLibrary:photoLibrary];
            configuration.preferredAssetRepresentationMode = PHPickerConfigurationAssetRepresentationModeAutomatic;
            [photoLibrary presentLimitedLibraryPickerFromViewController:self];
        } else {
            // Fallback on earlier versions
        }
    } else {
        NSLog(@"点击图片");
        if (self.isFull) {
            // 选满 - 未选中的照片
            if (model.isSelected == NO) {
                [self showFullAlertView];
                return;
            }
        }
        NSLog(@"查看大图");
        self.currentIndex = indexPath.item;
        [self previewPhotoAction];
    }
}

- (void)previewPhotoAction
{
    TTPhotoPageViewController * photoPageViewController = [[TTPhotoPageViewController alloc] init];
    if (self.isLimit) {
        NSMutableArray * newList = [NSMutableArray arrayWithArray:self.photoList];
        [newList removeLastObject];
        photoPageViewController.photoList = newList;
    } else {
        photoPageViewController.photoList = self.photoList;
    }
    photoPageViewController.selectedList = self.selectedList;
    photoPageViewController.startIndex = self.currentIndex;
    photoPageViewController.isMoreSelected = self.isMoreSelected;
    __weak typeof(self) weakSelf = self;
    photoPageViewController.reloadBlock = ^{
        [weakSelf.collectionView reloadData];
        [weakSelf updateNumberLabel];
    };
    [self.navigationController pushViewController:photoPageViewController animated:YES];
}

#pragma mark ---- PHPhotoLibraryChangeObserver
- (void)photoLibraryDidChange:(PHChange *)changeInstance
{
    NSLog(@"Not called");
    dispatch_async(dispatch_get_main_queue(), ^{
        // 初始化数据
        [self.selectedList removeAllObjects];
        self.isFull = NO;
        [self updateNumberLabel];
        [self loadPhotoData];
    });
}

#pragma mark --- Lazy Init
- (TTPhotoTopView *)topView
{
    if (nil == _topView) {
        _topView = [[TTPhotoTopView alloc] init];
        _topView.backgroundColor = [UIColor clearColor];
    }
    
    return _topView;
}

- (UICollectionView *)collectionView
{
    if (nil == _collectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        CGFloat width = (kSCREEN_WIDTH - 4)/4;
        flowLayout.itemSize = CGSizeMake(width, width);
        flowLayout.minimumLineSpacing = 1;
        flowLayout.minimumInteritemSpacing = 1;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kSCREEN_WIDTH, kSCREEN_HEIGHT) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        [_collectionView registerNib:[UINib nibWithNibName:NSStringFromClass(TTPhotoCollectionViewCell.class) bundle:nil] forCellWithReuseIdentifier:NSStringFromClass(TTPhotoCollectionViewCell.class)];
    }
    
    return _collectionView;
}

- (TTAlbumPermissionsView *)permissionsView
{
    if (nil == _permissionsView) {
        _permissionsView = [[TTAlbumPermissionsView alloc] init];
        _permissionsView.backgroundColor = [UIColor blackColor];
    }
    
    return _permissionsView;
}

- (TTPhotoBottomView *)bottomView
{
    if (nil == _bottomView) {
        _bottomView = [[TTPhotoBottomView alloc] init];
        _bottomView.backgroundColor = [UIColor clearColor];
    }
    
    return _bottomView;
}

@end
