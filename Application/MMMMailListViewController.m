#import "MMMMailListViewController.h"
#import "MMMMailViewController.h"
#import <objc/runtime.h>

@implementation MMMMailListViewController

- (BOOL)showsUnreadTint {
	return [_filter isEqualToDictionary:@{@"sent":@NO}];
}

- (instancetype)initWithFilter:(NSDictionary<NSString *, id> *)filter {
	if (filter && ![filter isKindOfClass:[NSDictionary class]]) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"The mail filter must be an NSDictionary."
		];
	}
	if ((self = [super initWithStyle:UITableViewStylePlain])) {
		_filter = filter;
		[MMUserDefaults addObserver:self forKey:@"mails" selector:@selector(reloadData)];
	}
	return self;
}

- (instancetype)init {
	return [self initWithFilter:nil];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return _mails.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc]
			initWithStyle:UITableViewCellStyleSubtitle
			reuseIdentifier:@"cell"
		];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.textLabel.numberOfLines = 1;
		cell.detailTextLabel.font = cell.textLabel.font;
		cell.detailTextLabel.textColor = [UIColor secondaryLabelColor];
		cell.detailTextLabel.numberOfLines = 3;
		cell.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
	}
	cell.backgroundColor = [cell.tintColor colorWithAlphaComponent:((_unread && !indexPath.row && self.showsUnreadTint) ? 0.25 : 0.0)];
	NSDate *date = _mails[indexPath.row][@"date"];
	NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:date];
	NSMutableAttributedString *attributedString = [NSMutableAttributedString new];
	BOOL aDayPassed = (delta >= 60*60*24);
	[attributedString appendAttributedString:[[NSAttributedString alloc]
		initWithString:[_mails[indexPath.row][@"title"] stringByAppendingString:@" "]
		attributes:@{
			NSForegroundColorAttributeName : [UIColor labelColor]
		}
	]];
	[attributedString appendAttributedString:[[NSAttributedString alloc]
		initWithString:[NSDateFormatter
			localizedStringFromDate:date
			dateStyle:aDayPassed ? NSDateFormatterShortStyle : NSDateFormatterNoStyle
			timeStyle:aDayPassed ? NSDateFormatterNoStyle : NSDateFormatterShortStyle
		]
		attributes:@{
			NSForegroundColorAttributeName : [UIColor secondaryLabelColor]
		}
	]];
	cell.textLabel.attributedText = attributedString.copy;
	cell.detailTextLabel.text = _mails[indexPath.row][@"content"];
	return cell;
}

- (void)reloadData {
	[MMUserDefaults acquireLockWithCompletion:^{
		[MMUserDefaults objectForKey:@"unread" completion:^(NSNumber *unread){
			if (self.showsUnreadTint) _unread = unread.boolValue;
			[MMUserDefaults objectForKey:@"mails" completion:^(NSArray *mails){
				NSMutableArray *filteredMails;
				if (!_filter.count) filteredMails = mails.mutableCopy;
				else {
					filteredMails = [NSMutableArray new];
					for (NSInteger i=mails.count-1; i>=0; i--) {
						NSMutableDictionary *mailData = (id)mails[i];
						BOOL filtered = NO;
						for (NSString *key in _filter) {
							if (![mailData[key] isEqual:_filter[key]]) {
								filtered = YES;
								break;
							}
						}
						if (filtered) continue;
						mailData = [mailData mutableCopy];
						mailData[@"index"] = @(i);
						[filteredMails addObject:mailData.copy];
					}
				}
				_mails = filteredMails.copy;
				[self.tableView reloadData];
				[MMUserDefaults releaseLock];
			}];
		}];
	}];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (!indexPath.row && _unread && self.showsUnreadTint) {
		[MMUserDefaults acquireLockWithCompletion:^{
			[MMUserDefaults setObject:@NO forKey:@"unread" completion:^{
				_unread = NO;
				[tableView
					reloadRowsAtIndexPaths:@[indexPath]
					withRowAnimation:UITableViewRowAnimationFade
				];
				[MMUserDefaults releaseLock];
			}];
		}];
	}
	NSUInteger mailIndex = [_mails[indexPath.row][@"index"] unsignedIntegerValue];
	MMMMailViewController *vc = [[MMMMailViewController alloc] initWithMailIndex:mailIndex];
	[self.navigationController pushViewController:vc animated:YES];
}

@end