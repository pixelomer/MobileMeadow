#import "MMMMailViewController.h"
#import "UIFont+MeadowFont.h"

@implementation MMMMailViewController

- (void)applyPlaceholderStar {
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
		initWithImage:[UIImage imageNamed:@"outline_grade_black"]
		style:UIBarButtonItemStylePlain
		target:nil
		action:nil
	];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor grayColor];
}

- (void)reloadData {
	[self applyPlaceholderStar];
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
			_starred = [dict[@"starred"] boolValue];
			self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
				initWithImage:[UIImage imageNamed:(_starred ? @"sharp_grade_black" : @"outline_grade_black")]
				style:UIBarButtonItemStylePlain
				target:self
				action:@selector(handleStarButton)
			];
			[_scrollView setNeedsLayout];
			[_scrollView layoutIfNeeded];
			[MMUserDefaults releaseLock];
		}];
	}];
}

- (void)handleStarButton {
	[MMUserDefaults acquireLockWithCompletion:^{
		[MMUserDefaults objectForKey:@"mails" completion:^(NSArray *mails){
			if (mails.count <= _mailIndex) {
				[MMUserDefaults releaseLock];
				[self.navigationController popViewControllerAnimated:YES];
				return;
			}
			NSMutableDictionary *dict = mails[_mailIndex];
			if (_date && ![_date isEqual:dict[@"date"]]) {
				[MMUserDefaults releaseLock];
				[self.navigationController popViewControllerAnimated:YES];
				return;
			}
			dict = dict.mutableCopy;
			dict[@"starred"] = @(!_starred);
			NSMutableArray *newMails = mails.mutableCopy;
			newMails[_mailIndex] = dict.copy;
			[MMUserDefaults setObject:newMails.copy forKey:@"mails" completion:^{
				[MMUserDefaults releaseLock];
			}];
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
	_letterTextLabel.font = [UIFont meadow_mailFont];
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
		[self applyPlaceholderStar];
	}
	return self;
}

@end