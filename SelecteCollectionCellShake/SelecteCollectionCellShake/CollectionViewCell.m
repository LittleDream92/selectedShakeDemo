//
//  CollectionViewCell.m
//  SelecteCollectionCellShake
//
//  Created by Meng Fan on 16/8/16.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//


/** 弱引用 */
#define WEAKSELF __weak typeof(self) weakSelf = self;

#import "CollectionViewCell.h"
#import "Masonry.h"

@implementation CollectionViewCell

/* 编辑状态下显示的对号 */
- (UIImageView *)editSelectedItemImageView
{
    if (!_editSelectedItemImageView) {
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.image = [UIImage imageNamed:@"book_check"];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        
        _editSelectedItemImageView = imageView;
    }
    return _editSelectedItemImageView;
}

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
        
        WEAKSELF
        [self.contentView addSubview:self.editSelectedItemImageView];
        [self.editSelectedItemImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(25, 25));
            make.center.equalTo(weakSelf.contentView).centerOffset(CGPointMake(0, 10));
        }];
        self.editSelectedItemImageView.hidden = YES;

        
        //添加长按手势
        UILongPressGestureRecognizer *longGT = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longGT:)];
        longGT.minimumPressDuration = 1.0;
        longGT.numberOfTouchesRequired = 1;
        longGT.allowableMovement = 10;
        [self addGestureRecognizer:longGT];
        
    }
    return self;
}



#pragma mark - action
- (void)longGT:(UILongPressGestureRecognizer *)gesture {
    if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(requestCellWithIndexPath:gesture:)]) {
        [self.cellDelegate requestCellWithIndexPath:self.indexPath gesture:gesture];
    }
}

@end
