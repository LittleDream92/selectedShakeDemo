//
//  ViewController.m
//  SelecteCollectionCellShake
//
//  Created by Meng Fan on 16/8/16.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import "ViewController.h"
#import "Masonry.h"
#import "CollectionViewCell.h"

#define kScreenSize [UIScreen mainScreen].bounds.size
/** 弱引用 */
#define WEAKSELF __weak typeof(self) weakSelf = self;

static NSString *const identifier = @"collectionCellIdentifier";
@interface ViewController ()<UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, MFCollectionCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) UIButton *cancelBtn;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIButton *deleteBtn;

@property (nonatomic, assign, getter=isEdit) BOOL edit;

/** 编辑选择的indexPath */
@property (nonatomic, strong) NSIndexPath *editSelectedIndexPath;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /** 编辑选择的indexPath:默认为(-1,-1)  */
    self.editSelectedIndexPath = [NSIndexPath indexPathForRow:-1 inSection:-1];
}

#pragma mark - setupViews
- (void)setupViews {
    WEAKSELF
    CGFloat width = kScreenSize.width-20*2-10*3;
    CGFloat height = kScreenSize.height-100;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(width/3, height/4);
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 20, 0, 10);
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).offset(64);
        make.left.equalTo(weakSelf.view);
        make.bottom.equalTo(weakSelf.view).offset(-100);
        make.width.equalTo(weakSelf.view);
    }];
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:identifier];
    
    [self setupOperationBtn];
}

- (void)setupOperationBtn {
    WEAKSELF
    [self.view addSubview:self.cancelBtn];
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(60, 60));
        make.bottom.equalTo(weakSelf.view).offset(60);
        make.left.equalTo(weakSelf.view).offset(30);
    }];
    
    [self.view addSubview:self.editBtn];
    [self.editBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(weakSelf.cancelBtn);
        make.bottom.equalTo(weakSelf.cancelBtn);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
    }];
    
    [self.view addSubview:self.deleteBtn];
    [self.deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(weakSelf.cancelBtn);
        make.right.equalTo(weakSelf.view.mas_right).offset(-30);
        make.bottom.equalTo(weakSelf.cancelBtn);
    }];
}

#pragma mark - lazy loading
-(UIButton *)cancelBtn {
    if (!_cancelBtn) {
        _cancelBtn = [[UIButton alloc] init];
        _cancelBtn.backgroundColor = [UIColor cyanColor];
        [_cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

-(UIButton *)editBtn {
    if (!_editBtn) {
        _editBtn = [[UIButton alloc] init];
        _editBtn.backgroundColor = [UIColor cyanColor];
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn addTarget:self action:@selector(edit:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

-(UIButton *)deleteBtn {
    if (!_deleteBtn) {
        _deleteBtn = [[UIButton alloc] init];
        _deleteBtn.backgroundColor = [UIColor cyanColor];
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn addTarget:self action:@selector(delete:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteBtn;
}

#pragma mark - action
- (void)cancel:(UIButton *)sender {
    NSLog(@"cancel");
    
    self.edit = NO;
    
    CollectionViewCell *cell = (CollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.editSelectedIndexPath];
    cell.editSelectedItemImageView.hidden = YES;
    
    
    [self.collectionView reloadData];
    WEAKSELF
    [UIView animateWithDuration:5.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(weakSelf.view).offset(60);
        }];
    } completion:nil];
}

- (void)edit:(UIButton *)sender {
    NSLog(@"edit");
}

- (void)delete:(UIButton *)sender {
    NSLog(@"delete");
}

#pragma mark - UICollectionViewDataSource
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 3;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    cell.cellDelegate = self;
    cell.indexPath = indexPath;
    
    if (self.edit) {
        if ([indexPath isEqual:self.editSelectedIndexPath]) {
            cell.editSelectedItemImageView.hidden = NO;
        } else {
            cell.editSelectedItemImageView.hidden = YES;
        }
        [self shakeCell:cell];
    }else {
        cell.editSelectedItemImageView.hidden = YES;
        //还原
        cell.transform = CGAffineTransformIdentity;
    }
    
    return cell;
}

/** 抖动动画 */
- (void)shakeCell:(CollectionViewCell *)cell {
    [UIView animateWithDuration:0.1 delay:0 options:0 animations:^{
        cell.transform=CGAffineTransformMakeRotation(-0.02);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.1 delay:0 options:UIViewAnimationOptionRepeat|UIViewAnimationOptionAutoreverse | UIViewAnimationOptionAllowUserInteraction animations:^{
            cell.transform=CGAffineTransformMakeRotation(0.02);
        } completion:nil];
    }];
}

#pragma mark - MFCollectionCellDelegate
-(void)requestCellWithIndexPath:(NSIndexPath *)indexPath gesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.editSelectedIndexPath = indexPath;
        self.edit = YES;
        [self.collectionView reloadData];
        WEAKSELF
        [UIView animateWithDuration:5.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(weakSelf.view.mas_bottom);
            }];
        } completion:nil];
    }
}



@end
