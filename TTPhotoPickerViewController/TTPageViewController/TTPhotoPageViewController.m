//
//  TTPhotoPageViewController.m
//  TTPhotoPickerViewController
//
//  Created by tangshuanghui on 2021/4/19.
//

#import "TTPhotoPageViewController.h"
#import "TTPhotoPageTopView.h"
#import "TTPhotoPageCollectionView.h"
#import "TTPhotoPageBottomView.h"

@interface TTPhotoPageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

@property (nonatomic, strong) UIPageViewController * pageViewController;
@property (nonatomic, strong) TTPhotoPageTopView * headerView;
@property (nonatomic, strong) TTPhotoPageCollectionView * photoView;
@property (nonatomic, strong) TTPhotoPageBottomView * bottomView;

@end

@implementation TTPhotoPageViewController

- (void)dealloc
{
    CheckRunWhere
}

- (TTPhotoPageTopView *)headerView
{
    if (nil == _headerView) {
        _headerView = [[TTPhotoPageTopView alloc] initWithFrame:CGRectZero];
        _headerView.backgroundColor = [UIColor blackColor];
    }
    
    return _headerView;
}

- (TTPhotoPageCollectionView *)photoView
{
    if (nil == _photoView) {
        _photoView = [[TTPhotoPageCollectionView alloc] initWithFrame:CGRectZero];
        _photoView.backgroundColor = [UIColor blackColor];
    }
    
    return _photoView;
}

- (TTPhotoPageBottomView *)bottomView
{
    if (nil == _bottomView) {
        _bottomView = [[TTPhotoPageBottomView alloc] initWithFrame:CGRectZero];
        _bottomView.backgroundColor = [UIColor blackColor];
    }
    
    return _bottomView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupPageViewControllerUI];
    self.headerView.isMoreSelected = self.isMoreSelected;
    [self.headerView.backButton addTarget:self action:@selector(backButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [self.headerView updatePhotoNumber:self.selectedList.count maxNumber:kImageMaxNumber];
    
    __weak typeof(self) weakSelf = self;
    self.photoView.photoList = self.selectedList;
    self.photoView.hidden = self.selectedList.count == 0 ? YES : NO;
    self.photoView.clickBlock = ^(TTPHAsset * model) {
        NSInteger index = [weakSelf.photoList indexOfObject:model];
        [weakSelf.pageViewController setViewControllers:@[[weakSelf viewControllerAtIndex:index]]
                                          direction:UIPageViewControllerNavigationDirectionForward
                                           animated:NO
                                         completion:nil];
        weakSelf.bottomView.model = model;
    };
    
    TTPHAsset * model = [self.photoList objectAtIndex:self.startIndex];
    self.bottomView.model = model;
    self.bottomView.clickBlock = ^(TTPHAsset * _Nonnull model) {
        [weakSelf handleSelectPhotoActionWith:model];
    };
    [self.view addSubview:self.headerView];
    [self.view addSubview:self.photoView];
    [self.view addSubview:self.bottomView];
}

- (void)handleSelectPhotoActionWith:(TTPHAsset *)model
{
    if (self.isMoreSelected) {
        // 多选
        model.isSelected = !model.isSelected;
        if ([self.selectedList containsObject:model]) {
            [self.selectedList removeObject:model];
        } else {
            if (self.selectedList.count >= kImageMaxNumber) {
                model.isSelected = !model.isSelected;
//                [self showFullAlertView];
                return;
            }
            [self.selectedList addObject:model];
        }
        // 处理图片顺序标识
        model.index = 0;
        for (NSInteger index = 0; index < self.selectedList.count; ++index) {
            TTPHAsset * member = self.selectedList[index];
            member.index = index + 1;
        }
        [self.bottomView updateShowUI];
    } else {
        // 单选图片逻辑处理
        for (TTPHAsset * member in self.photoList) {
            member.isSelected = NO;
        }
        model.isSelected = YES;
        [self.selectedList removeAllObjects];
        [self.selectedList addObject:model];
        [self.bottomView updateShowUI];
    }
    [self.headerView updatePhotoNumber:self.selectedList.count maxNumber:kImageMaxNumber];
    [self.photoView setPhotoList:self.selectedList];
    self.photoView.hidden = self.selectedList.count == 0 ? YES : NO;
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
    NSLog(@"self.view - insets - %@", NSStringFromUIEdgeInsets(edgeInsets));
    self.headerView.frame = CGRectMake(0, 0, frame.size.width, edgeInsets.top + 44);
    self.photoView.frame = CGRectMake(0, frame.size.height - edgeInsets.bottom - 110, frame.size.width, 80);
    self.bottomView.frame = CGRectMake(0, CGRectGetMaxY(self.photoView.frame), frame.size.width, frame.size.height - CGRectGetMaxY(self.photoView.frame));
}

- (void)backButtonAction
{
    if (self.reloadBlock) {
        self.reloadBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setupPageViewControllerUI
{
    NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(UIPageViewControllerSpineLocationMin)};
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self.pageViewController setViewControllers:@[[self viewControllerAtIndex:self.startIndex]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:nil];
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
}

#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate

#pragma mark 返回上一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [self indexOfViewController:(TTPhotoViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法,自动来维护次序
    // 不用我们去操心每个ViewController的顺序问题
    return [self viewControllerAtIndex:index];
}

#pragma mark 返回下一个ViewController对象
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    NSUInteger index = [self indexOfViewController:(TTPhotoViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.photoList count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed
{
    // 此方法确定当前页位置
    NSUInteger index = [self indexOfViewController:(TTPhotoViewController *)[pageViewController.viewControllers firstObject]];
    TTPHAsset * model = self.photoList[index];
    [self.bottomView setModel:model];
}

#pragma mark - 根据index得到对应的UIViewController
- (TTPhotoViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.photoList count] == 0) || (index >= [self.photoList count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    TTPhotoViewController * photoViewController = [[TTPhotoViewController alloc] init];
    photoViewController.model = self.photoList[index];
    photoViewController.index = index;
    
    return photoViewController;
}
 
#pragma mark - 数组元素值，得到下标值
- (NSUInteger)indexOfViewController:(TTPhotoViewController *)viewController {
    return [self.photoList indexOfObject:viewController.model];
}

@end
