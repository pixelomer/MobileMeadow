#import <UIKit/UIKit.h>

@interface MMBirdView : UIView {
	UIImageView *_imageView;
	NSArray<UIImage *> *_animationImages;
	UIImage *_groundImage;
	BOOL _isAnimating;
}
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, assign) CGSize size;
@property (nonatomic, assign) BOOL horizontallyMirrored;
@property (nonatomic, assign) CGFloat rotationInDegrees;
@property (atomic, copy) NSDictionary *userInfo;
- (instancetype)initWithBirdName:(NSString *)name;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;
- (CGSize)sizeThatFits:(CGSize)size; // same as -[MMBirdView size]
@end