#import <UIKit/UIKit.h>

@interface MMMMailListViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource> {
	NSArray<NSDictionary<NSString *, id> *> *_mails;
	BOOL _unread;
}
@property (nonatomic, copy, readonly) NSDictionary<NSString *, id> *filter; 
- (instancetype)initWithFilter:(NSDictionary<NSString *, id> *)filter;
- (void)reloadData;
@end