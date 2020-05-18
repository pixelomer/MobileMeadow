#import "MMUserDefaultsServer.h"

@implementation MMUserDefaultsServer

static BOOL _isRunning;
static NSString *_currentLockOwner;
static NSMutableArray<NSArray<NSString *> *> *_lockQueue;

+ (BOOL)isCurrentProcessServer {
	return _isRunning;
}

+ (void)runServerInMainThread {
	if (![NSThread isMainThread]) {
		dispatch_sync(dispatch_get_main_queue(), ^{ [self runServerInMainThread]; });
		return;
	}
	@synchronized (self) {
		if (!_isRunning) _isRunning = YES;
		else return;
	}
	if (![NSBundle.mainBundle.bundleIdentifier isEqualToString:@"com.apple.springboard"]) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"%@ can only run in SpringBoard", NSStringFromClass(self)
		];
	}
	_currentLockOwner = nil;
	_lockQueue = [NSMutableArray new];
	[[NSDistributedNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(clientWantsToReleaseLockWithNotification:)
		name:@"com.pixelomer.mobilemeadow/ReleaseLock"
		object:nil
		suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
	];
	[[NSDistributedNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(clientWantsToAcquireLockWithNotification:)
		name:@"com.pixelomer.mobilemeadow/AcquireLock"
		object:nil
		suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
	];
	[[NSDistributedNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(clientWantsToGetObjectWithNotification:)
		name:@"com.pixelomer.mobilemeadow/GetObject"
		object:nil
		suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
	];
	[[NSDistributedNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(clientWantsToSetObjectWithNotification:)
		name:@"com.pixelomer.mobilemeadow/SetObject"
		object:nil
		suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
	];
}

+ (void)terminateClient:(NSString *)bundleIdentifier exceptionName:(NSExceptionName)name message:(NSString *)message {
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/Error"
		object:bundleIdentifier
		userInfo:@{ @"exceptionName" : name, @"exceptionMessage" : message }
		deliverImmediately:YES
	];
}

+ (void)terminateClient:(NSString *)client withNoLockErrorForSelector:(SEL)selector {
	[self
		terminateClient:client
		exceptionName:NSInvalidArgumentException
		message:[NSString
			stringWithFormat:@"\"%@\" was called for a client that doesn't have the lock.",
			NSStringFromSelector(selector)
		]
	];
}

+ (void)pickNewLockOwnerIfNecessary {
	if (_currentLockOwner) return;
	NSArray *newOwnerData = _lockQueue.firstObject;
	if (!newOwnerData) return;
	[_lockQueue removeObjectAtIndex:0];
	_currentLockOwner = newOwnerData[0];
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/HeresYourLock"
		object:newOwnerData[0]
		userInfo:@{ @"completion" : newOwnerData[1] }
		deliverImmediately:YES
	];
}

+ (void)clientWantsToReleaseLockWithNotification:(NSNotification *)notif { @synchronized (self) {
	if (![_currentLockOwner isEqualToString:notif.object]) {
		[self terminateClient:notif.object withNoLockErrorForSelector:_cmd];
		return;
	}
	_currentLockOwner = nil;
	[self pickNewLockOwnerIfNecessary];
}}

+ (void)clientWantsToAcquireLockWithNotification:(NSNotification *)notif { @synchronized (self) {
	if (![notif.userInfo[@"completion"] isKindOfClass:[NSNumber class]] || !notif.object) return;
	[_lockQueue addObject:@[notif.object, notif.userInfo[@"completion"]]];
	[self pickNewLockOwnerIfNecessary];
}}

+ (void)clientWantsToGetObjectWithNotification:(NSNotification *)notif { @synchronized (self) {
	if ((![notif.userInfo[@"nolock"] isKindOfClass:[NSNumber class]]
		 || ![notif.userInfo[@"nolock"] boolValue]) &&
		![_currentLockOwner isEqualToString:notif.object])
	{
		[self terminateClient:notif.object withNoLockErrorForSelector:_cmd];
		return;
	}
	if (notif.userInfo[@"completion"]) {
		id object = [[NSUserDefaults standardUserDefaults]
			objectForKey:notif.userInfo[@"key"]
			inDomain:@"com.pixelomer.meadowmail"
		];
		NSDictionary *userInfo = (object ?
			@{ @"data" : object, @"completion" : notif.userInfo[@"completion"] } :
			@{ @"completion" : notif.userInfo[@"completion"] }
		);
		[[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.pixelomer.mobilemeadow/HeresYourData"
			object:notif.object
			userInfo:userInfo
			deliverImmediately:YES
		];
	}
}}

+ (void)clientWantsToSetObjectWithNotification:(NSNotification *)notif { @synchronized (self) {
	if (![_currentLockOwner isEqualToString:notif.object]) {
		[self terminateClient:notif.object withNoLockErrorForSelector:_cmd];
		return;
	}
	id old = [[NSUserDefaults standardUserDefaults]
		objectForKey:notif.userInfo[@"key"]
		inDomain:@"com.pixelomer.meadowmail"
	];
	[[NSUserDefaults standardUserDefaults]
		setObject:notif.userInfo[@"object"]
		forKey:notif.userInfo[@"key"]
		inDomain:@"com.pixelomer.meadowmail"
	];
	if (notif.userInfo[@"completion"]) {
		[[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.pixelomer.mobilemeadow/SetObjectCompleted"
			object:notif.object
			userInfo:@{ @"completion" : notif.userInfo[@"completion"] }
			deliverImmediately:YES
		];
	}
	NSMutableDictionary *dict = [NSMutableDictionary new];
	if (old) dict[@"old"] = old;
	if (notif.userInfo[@"object"]) dict[@"new"] = notif.userInfo[@"object"];
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/ValueForKeyChanged"
		object:notif.userInfo[@"key"]
		userInfo:dict
		deliverImmediately:YES
	];
}}

@end