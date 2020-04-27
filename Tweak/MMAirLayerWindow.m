#import "MMAirLayerWindow.h"
#import "MMBirdView.h"
#import "MMAirLayerViewController.h"
#import <Headers/SpringBoard.h>

@implementation MMAirLayerWindow

static MMAirLayerWindow *_sharedInstance;

+ (instancetype)sharedInstance {
	return _sharedInstance;
}

+ (NSString *)randomBirdName {
	static NSArray *array;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		array = @[
			@"ufo",
			@"redbird",
			@"greenbird"
		];
	});
	return array[arc4random_uniform(array.count)];
}

- (instancetype)init {
	if ((self = [super initWithFrame:UIScreen.mainScreen.bounds])) {
		_newBirdTimer = [NSTimer
			scheduledTimerWithTimeInterval:(2.0)
			target:self
			selector:@selector(randomEventTimerTick:)
			userInfo:nil
			repeats:YES
		];
		self.rootViewController = [MMAirLayerViewController new];
		self.rootViewController.view.backgroundColor = [UIColor clearColor];
		_sharedInstance = self;
	}
	return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
	return nil;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
	return NO;
}

- (void)animateBirdWithName:(NSString *)birdName
	initialPosition:(CGPoint)initialPoint
	finalPoisition:(CGPoint)finalPoint
	completion:(void(^)(BOOL))completion
	speed:(CGFloat)speed
{
	MMBirdView *bird = [[MMBirdView alloc] initWithBirdName:birdName];
	UIOffset dummyOffset = UIOffsetMake(
		((initialPoint.x > finalPoint.x) ? -1.0 : 1.0),
		((initialPoint.y > finalPoint.y) ? -1.0 : 1.0)
	);
	CGFloat distance = hypotf(initialPoint.x-finalPoint.x, initialPoint.y-finalPoint.y);
	NSTimeInterval duration = (distance/150.0)/speed;
	CGRect frame;
	frame.origin = initialPoint;
	frame.size = bird.size;
	bird.frame = frame;
	bird.userInfo = @{
		@"animationOffset" : [NSValue valueWithUIOffset:dummyOffset]
	};
	[self.rootViewController.view addSubview:bird];
	frame.origin = finalPoint;
	[UIView
		animateWithDuration:duration
		delay:0.0
		options:UIViewAnimationOptionCurveLinear
		animations:^{
			bird.frame = frame;
		}
		completion:^(BOOL finished){
			[bird removeFromSuperview];
			completion(finished);
		}
	];
}

- (void)randomEventTimerTick:(NSTimer *)timer {
	if ([(SpringBoard *)UIApplication.sharedApplication isLocked]) return;
	unsigned long randomValue = arc4random_uniform(100);
	switch (randomValue) {
		case 10 ... 25: {
			MMBirdView *bird = [[MMBirdView alloc] initWithBirdName:[self.class randomBirdName]];
			UIOffset offset = UIOffsetMake(
				((CGFloat)arc4random_uniform(900) / 100.0) - 4.5,
				((CGFloat)arc4random_uniform(900) / 100.0) - 4.5
			);
			if ((offset.horizontal < 0.0) && (offset.horizontal > -2.0)) offset.horizontal -= 2.0;
			if ((offset.horizontal > 0.0) && (offset.horizontal < 2.0)) offset.horizontal += 2.0;
			CGFloat sw = UIScreen.mainScreen.bounds.size.width;
			CGFloat sh = UIScreen.mainScreen.bounds.size.height;
			if ([(MMAirLayerViewController *)self.rootViewController isLandscape]) {
				CGFloat st = sw;
				sw = sh;
				sh = st;
			}
			CGPoint initialPosition = CGPointMake(
				(offset.horizontal > 0.0) ? -bird.size.width : sw,
				arc4random_uniform((unsigned long)(sh - 100.0)) + 50.0
			);
			CGRect frame;
			frame.origin = initialPosition;
			frame.size = bird.size;
			bird.frame = frame;
			bird.userInfo = @{
				@"animationOffset" : [NSValue valueWithUIOffset:offset]
			};
			[self.rootViewController.view addSubview:bird];
			CGFloat finalX = initialPosition.x, finalY = initialPosition.y;
			NSTimeInterval duration = 0.0;
			while ((finalX <= sw) && (finalX >= -bird.size.width)) {
				duration += (1.0/30.0);
				finalX += offset.horizontal;
				finalY += offset.vertical;
			}
			frame.origin.x = finalX;
			frame.origin.y = finalY;
			[UIView
				animateWithDuration:duration
				delay:0.0
				options:UIViewAnimationOptionCurveLinear // | UIViewAnimationOptionPreferredFramesPerSecond30
				animations:^{
					bird.frame = frame;
				}
				completion:^(BOOL finished){
					[bird removeFromSuperview];
				}
			];
		}
	}
}

@end