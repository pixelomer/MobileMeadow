#import "MMMailManager.h"
#import "MMAirLayerWindow.h"
#import "MMGroundContainerView.h"
#import <Headers/SpringBoard.h>

// GET request: Gets a random letter
// POST request: Sends a letter (has to be approved by a moderator)

@implementation MMMailManager

static NSArray *hours = nil;
static BOOL canReceiveMail = NO;

+ (void)load {
	if ([MMMailManager class] == self) {
		hours = @[
			@(3), @(7), @(10), @(13),
			@(17), @(20), @(22)
		];
		canReceiveMail = YES;
		[NSNotificationCenter.defaultCenter
			addObserver:self
			selector:@selector(handleMailBoxStateChange:)
			name:@"MMMailBoxView/StateChange"
			object:nil
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

+ (void)handleMailBoxStateChange:(NSNotification *)notif {
	NSNumber *isFull = notif.userInfo[@"isFull"];
	if (![isFull boolValue] && !canReceiveMail) {
		NSLog(@"Mailbox was checked. Will set canReceiveMail to YES.");
		canReceiveMail = YES;
	}
}

+ (void)mailThread:(id)unused {
	NSLog(@"+mailThread: got called.");
	if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"New mails can only be fetched in SpringBoard."
		];
	}
	[NSThread sleepForTimeInterval:60.0];
	while (1) {
		NSDate *currentDate = [NSDate date];
		NSDate *dateToSleepUntil = [currentDate dateByAddingTimeInterval:60.0];
		[self oneMinuteDidPass];
		currentDate = [NSDate date];
		NSTimeInterval secondsToSleep = dateToSleepUntil.timeIntervalSince1970 - currentDate.timeIntervalSince1970;
		NSLog(@"Seconds to sleep: %f", secondsToSleep);
		if ((secondsToSleep < 60.0) && (secondsToSleep > 0.0)) {
			[NSThread sleepUntilDate:dateToSleepUntil];
		}
	}
}

+ (NSString *)fetchLetter {
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
		![dict[@"message"] isKindOfClass:[NSString class]]) return nil;
	NSLog(@"Response contains the message.");
	return dict[@"message"];
}

+ (void)notifyUserAboutNewMail:(NSString *)letter {

}

+ (void)animateBirdLanding:(NSString *)letter {
	MMGroundContainerView *view = [MMGroundContainerView springboardSingleton];
	[view animateDeliveryBirdLandingWithCompletion:^(BOOL finished){
		[self notifyUserAboutNewMail:letter];
	}];
}

+ (void)animateMailArrival:(NSString *)letter {
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
	NSLog(@"One minute passed. Can receive mail: %d", canReceiveMail);
	if (!canReceiveMail) return;
	canReceiveMail = NO;
#define return do { canReceiveMail = YES; return; } while (0)
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDate *date = [NSDate date];
	NSCalendarUnit flags = (NSCalendarUnitMinute | NSCalendarUnitHour);
	NSDateComponents *components = [calendar components:flags fromDate:date];
	NSLog(@"It's %02ld:%02ld. Checking if mail should be delivered...", (long)components.hour, (long)components.minute);
//#if !DEBUG
	if (!components) return;
	if (components.minute) return;
	for (NSNumber *hour in hours) {
		if (hour.integerValue == components.hour) {
			calendar = nil;
			break;
		}
	}
	if (calendar) return;
//#endif
	NSLog(@"It's time to deliver mail!");
	NSString *letterString = [self fetchLetter];
	NSLog(@"Letter: %@", letterString);
	if (!letterString) return;
	dispatch_async(dispatch_get_main_queue(), ^{
		[self animateMailArrival:letterString];
	});
#undef return
}

@end