#import "MMMAboutViewController.h"
#import "UIColor+MeadowMail.h"

@implementation MMMAboutViewController

static NSArray *_aboutContent;

+ (void)load {
	if (self == [MMMAboutViewController class]) {
		_aboutContent = ABOUT_CONTENT_ARRAY;
	}
}

+ (NSArray *)aboutContent {
	return _aboutContent;
}

+ (void)setAboutContent:(NSArray *)aboutContent {
	// This method was used by the moderator tools. Since there is nothing to moderate
	// anymore, this method is empty.
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
	NSString *URLString = [rowData objectAtIndex:1];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:URLString]];
	[self.tableView deselectRowAtIndexPath:indexPath animated:NO];
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
	cell.textLabel.textColor = self.view.tintColor;
	cell.accessoryType = UITableViewCellAccessoryNone;
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