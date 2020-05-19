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
			[_scrollView setNeedsLayout];
			[_scrollView layoutIfNeeded];
			[MMUserDefaults releaseLock];
		}];
	}];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	_scrollView = [MMMMailScrollView new];
	self.view.backgroundColor = _scrollView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mail_background_tile"]];
	_scrollView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.view addSubview:_scrollView];
	[self.view addConstraints:@[
		[NSLayoutConstraint
			constraintWithItem:_scrollView
			attribute:NSLayoutAttributeTop
			relatedBy:NSLayoutRelationEqual
			toItem:self.topLayoutGuide
			attribute:NSLayoutAttributeBottom
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_scrollView
			attribute:NSLayoutAttributeBottom
			relatedBy:NSLayoutRelationEqual
			toItem:self.bottomLayoutGuide
			attribute:NSLayoutAttributeTop
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_scrollView
			attribute:NSLayoutAttributeLeft
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeLeft
			multiplier:1.0
			constant:0.0
		],
		[NSLayoutConstraint
			constraintWithItem:_scrollView
			attribute:NSLayoutAttributeRight
			relatedBy:NSLayoutRelationEqual
			toItem:self.view
			attribute:NSLayoutAttributeRight
			multiplier:1.0
			constant:0.0
		]
	]];
	_letterTextLabel = [UILabel new];
	_letterTextLabel.font = _font;
	self.edgesForExtendedLayout = UIRectEdgeAll;
	_letterTextLabel.textColor = [UIColor blackColor];
	_letterTextLabel.numberOfLines = 0;
	[_scrollView addSubview:_letterTextLabel];
	_scrollView.letterTextLabel = _letterTextLabel;
	_topLeftImageView = [UIImageView new];
	_topLeftImageView.image = [UIImage imageNamed:@"mail_top_left"];
	[_scrollView addSubview:_topLeftImageView];
	_scrollView.topLeftImageView = _topLeftImageView;
	_bottomRightImageView = [UIImageView new];
	_bottomRightImageView.image = [UIImage imageNamed:@"mail_bottom_right"];
	[_scrollView addSubview:_bottomRightImageView];
	_scrollView.bottomRightImageView = _bottomRightImageView;
	[_scrollView setNeedsLayout];
	[_scrollView layoutIfNeeded];
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