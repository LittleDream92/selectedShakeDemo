//
//  CollectionViewCell.h
//  SelecteCollectionCellShake
//
//  Created by Meng Fan on 16/8/16.
//  Copyright © 2016年 Meng Fan. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MFCollectionCellDelegate <NSObject>

@required
@optional
- (void)requestCellWithIndexPath:(NSIndexPath *)indexPath gesture:(UILongPressGestureRecognizer *)gesture;

@end


@interface CollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) id<MFCollectionCellDelegate> cellDelegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

/** 编辑时候选择的 */
@property (nonatomic, strong) UIImageView *editSelectedItemImageView;

@end
