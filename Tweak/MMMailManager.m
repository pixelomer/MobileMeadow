#import "MMMailManager.h"
#import "MMAirLayerWindow.h"
#import "MMGroundContainerView.h"

// GET request: Gets a random letter
// POST request: Send a letter (has to be approved by a moderator)

@implementation MMMailManager

static NSArray *hours = nil;
static BOOL canReceiveMail = NO;
static NSTimer *canReceiveMailTimer = nil;
static NSTimer *oneMinuteTimer = nil;

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
	if (!oneMinuteTimer) {
		[NSThread
			detachNewThreadSelector:@selector(mailThread:)
			toTarget:self
			withObject:nil
		];
	}
}

+ (void)canNowReceiveMail:(NSTimer *)timer {
	NSLog(@"2 minutes passed. Can now receive mail.");
	[canReceiveMailTimer invalidate];
	if (timer != canReceiveMailTimer) [timer invalidate];
	canReceiveMailTimer = nil;
	canReceiveMail = YES;
}

+ (void)handleMailBoxStateChange:(NSNotification *)notif {
	NSNumber *isFull = notif.userInfo[@"isFull"];
	if (![isFull boolValue] && !canReceiveMail) {
		NSLog(@"Mailbox was checked. Will set canReceiveMail to YES in 2 minutes.");
		[canReceiveMailTimer invalidate];
		canReceiveMailTimer = [NSTimer
			scheduledTimerWithTimeInterval:120.0
			target:self
			selector:@selector(canNowReceiveMail:)
			userInfo:nil
			repeats:NO
		];
	}
}

+ (void)mailThread:(id)unused {
	oneMinuteTimer = [NSTimer
		scheduledTimerWithTimeInterval:60.0
		target:self
		selector:@selector(oneMinuteDidPass:)
		userInfo:nil
		repeats:YES
	];
	while (1) {
		[[NSRunLoop currentRunLoop] run];
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

+ (void)oneMinuteDidPass:(NSTimer *)timer {
	NSLog(@"One minute passed. Can receive mail: %d", canReceiveMail);
	if (!canReceiveMail) return;
	canReceiveMail = NO;
#define return do { canReceiveMail = YES; return; } while (0)
	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
	NSDate *date = [NSDate date];
	NSCalendarUnit flags = (NSCalendarUnitMinute | NSCalendarUnitHour);
	NSDateComponents *__debug_unused components = [calendar components:flags fromDate:date];
	NSLog(@"Checking time.");
#if DEBUG
	if (!components) return;
	if (components.minute) return;
	for (NSNumber *hour in hours) {
		if (hour.integerValue == components.hour) {
			calendar = nil;
			break;
		}
	}
	if (calendar) return;
#endif
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