#import "MMMAboutViewController.h"
#import "UIColor+MeadowMail.h"

@implementation MMMAboutViewController

static NSArray *_aboutContent;

+ (void)load {
	if (self == [MMMAboutViewController class]) {
		_aboutContent = @[
			@[@"Credits", @"", @[
				@[@"@pixelomer (Developer)", [NSURL URLWithString:@"https://twitter.com/pixelomer"]],
				@[@"@Skittyblock (Tester)", [NSURL URLWithString:@"https://twitter.com/Skittyblock"]],
				@[@"@SamNChiet (Assets and Idea)", [NSURL URLWithString:@"https://twitter.com/SamNChiet"]],
				@[@"Google (Star Icon)", [NSURL URLWithString:@"https://material.io"]],
				@[@"OpenDyslexic (Letter Font)", [NSURL URLWithString:@"https://opendyslexic.org"]]
			]],
			@[@"Additional Links", @"If you downloaded MobileMeadow from a source other than the official source, please switch to the official source.", @[
				@[@"Official Source", [NSURL URLWithString:@"https://repo.pixelomer.com"]],
				@[@"Desktop Meadow by @SamNChiet", [NSURL URLWithString:@"https://samperson.itch.io/meadow"]]
			]]
		];
	}
}

+ (NSArray *)aboutContent {
	return _aboutContent;
}

+ (void)setAboutContent:(NSArray *)aboutContent {
	_aboutContent = aboutContent;
}

- (void)handleDismissButton {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (instancetype)init {
	if ((self = [super initWithStyle:UITableViewStyleGrouped])) {
		self.title = @"About MobileMeadow";
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
			initWithTitle:@"Done"
			style:UIBarButtonItemStyleDone
			target:self
			action:@selector(handleDismissButton)
		];
	}
	return self;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *rowData = [[_aboutContent[indexPath.section] objectAtIndex:2] objectAtIndex:indexPath.row];
	id object = [rowData objectAtIndex:1];
	if ([object isKindOfClass:[NSURL class]]) {
		[[UIApplication sharedApplication] openURL:object];
		[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
	}
	else if ([object isKindOfClass:[NSString class]]) {
		UIViewController *vc = [NSClassFromString(object) new];
		vc.title = [rowData objectAtIndex:0];
		[self.navigationController pushViewController:vc animated:YES];
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [[_aboutContent[section] objectAtIndex:2] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (!cell) {
		cell = [[UITableViewCell alloc]
			initWithStyle:UITableViewCellStyleDefault
			reuseIdentifier:@"cell"
		];
		cell.textLabel.textColor = self.view.tintColor;
	}
	NSArray *rowData = [[_aboutContent[indexPath.section] objectAtIndex:2] objectAtIndex:indexPath.row];
	if ([rowData[1] isKindOfClass:[NSString class]]) {
		cell.textLabel.textColor = [UIColor meadow_labelColor];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	}
	else if ([rowData[1] isKindOfClass:[NSURL class]]) {
		cell.textLabel.textColor = self.view.tintColor;
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.textLabel.text = rowData[0];
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return [_aboutContent[section] objectAtIndex:0];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	NSString *footer = [_aboutContent[section] objectAtIndex:1];
	return footer.length ? footer : nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return _aboutContent.count;
}

@end