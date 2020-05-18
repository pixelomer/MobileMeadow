#import "MMMMailViewController.h"
#import <CoreText/CoreText.h>

@implementation MMMMailViewController

static UIFont *_font;

+ (void)initialize {
	if (self == [MMMMailViewController class]) {
		CGDataProviderRef fontDataRef = CGDataProviderCreateWithFilename(
			[NSBundle.mainBundle
				pathForResource:@"OpenDyslexic3-Regular"
				ofType:@"ttf"
			].UTF8String
		);
		CGFontRef fontRef = CGFontCreateWithDataProvider(fontDataRef);
		CFRelease(fontDataRef);
		CTFontRef graphicsFontRef = CTFontCreateWithGraphicsFont(fontRef, 15.5, NULL, NULL);
		CFRelease(fontRef);
		_font = [(__bridge UIFont *)graphicsFontRef copy];
		CFRelease(graphicsFontRef);
	}
}

- (void)reloadData {
	[MMUserDefaults acquireLockWithCompletion:^{
		[MMUserDefaults objectForKey:@"mails" completion:^(NSArray *mails){
			if (mails.count <= _mailIndex) {
				[MMUserDefaults releaseLock];
				[self.navigationController popViewControllerAnimated:YES];
				return;
			}
			NSDictionary *dict = mails[_mailIndex];
			if (_date && ![_date isEqual:dict[@"date"]]) {
				[MMUserDefaults releaseLock];
				[self.navigationController popViewControllerAnimated:YES];
				return;
			}
			_date = dict[@"date"];
			self.title = dict[@"title"];
			_letterTextLabel.text = dict[@"content"];
			[MMUserDefaults releaseLock];
		}];
	}];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mail_background_tile"]];
	_letterTextLabel = [UILabel new];
	_letterTextLabel.font = _font;
	self.edgesForExtendedLayout = UIRectEdgeAll;
	_letterTextLabel.textColor = [UIColor blackColor];
	_letterTextLabel.numberOfLines = 0;
	_letterTextLabel.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_letterTextLabel];
	[self.view addConstraints:@[
		[NSLayoutConstraint
			constraintWithItem:_letterTextLabel
			attribute:NSLayoutAttributeBottom
			relatedBy:NSLayoutRelationLessThanOrEqual
			toItem:self.bottomLayoutGuide
			attribute:NSLayoutAttributeTop
			multiplier:1.0
			constant:-20.0
		],
		[NSLayoutConstraint
			constraintWithItem:_letterTextLabel
			attribute:NSLayoutAttributeHeight
			relatedBy:NSLayoutRelationGreaterThanOrEqual
			toItem:nil
			attribute:NSLayoutAttributeNotAnAttribute
			multiplier:0.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_letterTextLabel
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:self.topLayoutGuide
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:20.0
		],
		[NSLayoutConstraint
			constraintWithItem:_letterTextLabel
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:20.0
		],
		[NSLayoutConstraint
			constraintWithItem:_letterTextLabel
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:-20.0
		]
	]];
	[self reloadData];
	[MMUserDefaults addObserver:self forKey:@"mails" selector:@selector(reloadData)];
}

- (instancetype)initWithMailIndex:(NSUInteger)index {
	if ((self = [super init])) {
		_mailIndex = index;
	}
	return self;
}

@end