#import <UIKit/UIKit.h>

@interface MMMRootViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource>
+ (NSArray *)rowTitles;
+ (NSArray *)rowFilters;
@end