#import "MMMRootViewController.h"
#import "IQKeyboardManager/IQKeyboardManager.h"
#import "MMMMailListViewController.h"

@implementation MMMRootViewController

static NSArray *_rowFilters;
static NSArray *_rowTitles;

- (instancetype)init {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		self.title = @"MobileMeadow Mail";
	}
	return self;
}

- (void)viewDidLoad {
	[IQKeyboardManager sharedManager].enable = YES;
	[super viewDidLoad];
}

+ (NSArray *)rowFilters {
	return _rowFilters;
}

+ (NSArray *)rowTitles {
	return _rowTitles;
}

+ (void)load {
	if (self == [MMMRootViewController class]) {
		_rowFilters = @[
			@{@"sent":@NO},
			@{@"sent":@YES},
			@{@"starred":@YES}
		];
		_rowTitles = @[
			@"Inbox",
			@"Sent",
			@"Starred"
		];
	}
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"lastVCIndex"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[NSUserDefaults standardUserDefaults] setObject:@(indexPath.row) forKey:@"lastVCIndex"];
	MMMMailListViewController *vc = [[MMMMailListViewController alloc] initWithFilter:_rowFilters[indexPath.row]];
	vc.title = _rowTitles[indexPath.row];
	[self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return section ? 0 : _rowTitles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc]
			initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:@"cell"
		];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	if (indexPath.section == 0) {
		cell.textLabel.text = _rowTitles[indexPath.row];
	}
	return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

@end