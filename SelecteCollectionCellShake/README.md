###效果图
![这里写图片描述](http://img.blog.csdn.net/20160816165932167)

		本demo实现的是collection cell长按出现操作按钮并且cell有摇晃的效果，点击取消，隐藏操作按钮，动画停止。

###实现
####用Masonry布局和自定义的delegate方法实现

 1. 初始化collectionView和三个操作按钮，用masonry布局，三个按钮位置在view的下边，看不到即可；
 2. collectionView自定义collectionViewCell，自定义delegate方法；

	```
	@protocol MFCollectionCellDelegate <NSObject>
	
	@required
	@optional
	- (void)requestCellWithIndexPath:(NSIndexPath *)indexPath gesture:(UILongPressGestureRecognizer *)gesture;
	
	@end
	```

 3. 给collectionViewCell添加长按手势，在手势的触发方法中让代理实现代理方法；

	```
	if (self.cellDelegate && [self.cellDelegate respondsToSelector:@selector(requestCellWithIndexPath:gesture:)]) {
	        [self.cellDelegate requestCellWithIndexPath:self.indexPath gesture:gesture];
	    }
	```
 4. 在viewController中定义一个BOOL类型的属性，纪录collectionView的编辑状态，在cell的dataSource方法中，通过编辑状态设置是否有摇晃动画；


	```
	if (self.edit) {
	        [self shakeCell:cell];
	    }else {
		    //还原
	        cell.transform = CGAffineTransformIdentity;
	    }
	```
	```
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
	```
 5. 设置controller为cell的代理，实现代理方法，在代理方法中，更新三个操作按钮的frame（因为初始化三个按钮时都是参照第取消按钮设置的，因此只用更新取消按钮的frame即可），更新编辑状态，reload collectionView；
	 

	```
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
	```

 6. 点击取消按钮时触发的方法中，实现更换编辑装套，更新collectionView，更新取消按钮的frame；
 

	```
	self.edit = NO;
	[self.collectionView reloadData];
	    WEAKSELF
	    [UIView animateWithDuration:5.0 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
	        [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
	            make.bottom.equalTo(weakSelf.view).offset(60);
	        }];
	    } completion:nil];
	```
	