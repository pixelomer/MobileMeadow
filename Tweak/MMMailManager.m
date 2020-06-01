#import "MMMailManager.h"
#import "MMAirLayerWindow.h"
#import "MMGroundContainerView.h"
#import <Headers/SpringBoard.h>
#import <objc/runtime.h>

// GET request: Gets a random letter
// POST request: Sends a letter (has to be approved by a moderator)

@implementation MMMailManager

static NSArray *hours = nil;
static BOOL isReceivingMail = NO;

+ (void)load {
	if ([MMMailManager class] == self) {
		hours = @[
			@(3), @(7), @(10), @(13),
			@(17), @(20), @(22)
		];
	}
}

+ (void)startMailThread {
	[NSThread
		detachNewThreadSelector:@selector(mailThread:)
		toTarget:self
		withObject:nil
	];
}

+ (void)unreadKey:(NSString *)key changedFromValue:(NSNumber *)oldValue toValue:(NSNumber *)newValue {
	if ([oldValue boolValue] && ![newValue boolValue] && MMMailBoxView.isFull) {
		[[MMGroundContainerView springboardSingleton]
			animateDeliveryBirdLeavingWithCompletion:nil
		];
	}
}

+ (BOOL)canReceiveMail {
	return !MMMailBoxView.isFull && !isReceivingMail;
}

+ (void)mailThread:(id)unused {
	if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"New mails can only be fetched in SpringBoard."
		];
	}
	[MMUserDefaults addObserver:self forKey:@"unread" selector:@selector(unreadKey:changedFromValue:toValue:)];
	[NSThread sleepForTimeInterval:60.0];
	while (1) {
		NSDate *currentDate = [NSDate date];
		NSDate *dateToSleepUntil = [currentDate dateByAddingTimeInterval:60.0];
		[self oneMinuteDidPass];
		currentDate = [NSDate date];
		NSTimeInterval secondsToSleep = [dateToSleepUntil timeIntervalSinceDate:currentDate];
		if ((secondsToSleep < 60.0) && (secondsToSleep > 0.2)) {
			secondsToSleep -= 0.1; // ¯\_(ツ)_/¯
			[NSThread sleepForTimeInterval:secondsToSleep];
		}
	}
}

+ (NSArray *)fetchLetter {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://api.pixelomer.com/meadow/v0/letter"]];
	request.timeoutInterval = 30.0;
	request.allowsCellularAccess = YES;
	NSHTTPURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection
		sendSynchronousRequest:request
		returningResponse:(id *)&response
		error:&error
	];
	NSLog(@"Error: %@", error);
	if (!data || (response.statusCode != 200)) return nil;
	NSDictionary *dict = [NSJSONSerialization
		JSONObjectWithData:data
		options:0
		error:nil
	];
	NSLog(@"Dict: %@", dict);
	if (![dict[@"success"] isKindOfClass:[NSNumber class]] ||
		![dict[@"success"] boolValue] ||
		![dict[@"message"] isKindOfClass:[NSString class]] ||
		![dict[@"title"] isKindOfClass:[NSString class]]) return nil;
	NSLog(@"Response contains the message.");
	return @[dict[@"title"], dict[@"message"]];
}

+ (void)notifyUserAboutNewMail:(NSArray *)letter {
	[MMUserDefaults acquireLockWithCompletion:^{
		[MMUserDefaults objectForKey:@"mails" completion:^(NSArray *data){
			NSArray *mailArray = data;
			NSDictionary *newDict = @{
				@"content":letter[1],
				@"date":[NSDate date],
				@"title":letter[0],
				@"sent":@NO,
				@"starred":@NO
			};
			if (!mailArray) mailArray = @[newDict];
			else mailArray = [mailArray arrayByAddingObject:newDict];
			[MMUserDefaults setObject:@YES forKey:@"unread" completion:^{
				[MMUserDefaults setObject:mailArray forKey:@"mails" completion:^{
					[MMUserDefaults releaseLock];
				}];
			}];
		}];
	}];
}

+ (void)animateBirdLanding:(NSArray *)letter {
	MMGroundContainerView *view = [MMGroundContainerView springboardSingleton];
	[view animateDeliveryBirdLandingWithCompletion:^(BOOL finished){
		isReceivingMail = NO;
		[self notifyUserAboutNewMail:letter];
	}];
}

+ (void)animateMailArrival:(NSArray *)letter {
	MMAirLayerWindow *window = [MMAirLayerWindow sharedInstance];
	CGRect rect = UIScreen.mainScreen.bounds;
	[window
		animateBirdWithName:@"deliverybird"
		initialPosition:CGPointMake(-100, 100)
		finalPoisition:CGPointMake(min(rect.size.width, rect.size.height), 100)
		completion:^(BOOL finished){
			[self animateBirdLanding:letter];
		}
		speed:1.75
	];
}

+ (void)oneMinuteDidPass {
	if (!self.canReceiveMail) return;
	isReceivingMail = YES;
#define return do { isReceivingMail = NO; return; } while (0)
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDate *date = [NSDate date];
	NSCalendarUnit flags = (NSCalendarUnitMinute | NSCalendarUnitHour);
	NSDateComponents *components = [calendar components:flags fromDate:date];
	NSLog(@"It's %02ld:%02ld. Checking if mail should be delivered...", (long)components.hour, (long)components.minute);
#if MEADOW_TESTER_BUILD
	goto skip;
#endif
	if (!components) return;
	if (components.minute) return;
	for (NSNumber *hour in hours) {
		if (hour.integerValue == components.hour) {
			calendar = nil;
			break;
		}
	}
	if (calendar) return;
#if MEADOW_TESTER_BUILD
	skip:
#endif
	NSLog(@"It's time to deliver mail!");
	NSArray *letter = [self fetchLetter];
	NSLog(@"Letter: %@", letter);
	if (!letter) return;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self animateMailArrival:letter];
	});
#undef return
}

@end