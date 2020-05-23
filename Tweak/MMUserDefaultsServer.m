#import "MMUserDefaultsServer.h"
#import <objc/runtime.h>
#import "MMUserDefaults.h"

@implementation MMUserDefaultsServer

static BOOL _isRunning;
static NSString *_currentLockOwner;
static NSMutableArray<NSArray<NSString *> *> *_lockQueue;
static BOOL _isRemoteNotification;
static NSDictionary<NSString *, NSString *> *_selectorDictionary;

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
	_selectorDictionary = @{
		@"com.pixelomer.mobilemeadow/ReleaseLock" : @"clientWantsToReleaseLockWithNotification:",
		@"com.pixelomer.mobilemeadow/AcquireLock" : @"clientWantsToAcquireLockWithNotification:",
		@"com.pixelomer.mobilemeadow/GetObject" : @"clientWantsToGetObjectWithNotification:",
		@"com.pixelomer.mobilemeadow/SetObject" : @"clientWantsToSetObjectWithNotification:",
		@"com.pixelomer.mobilemeadow/RespondIfAlive" : @"clientWantsToKnowThatTheServerIsAliveWithNotification:"
	};
	_currentLockOwner = nil;
	_lockQueue = [NSMutableArray new];
	for (NSString *name in _selectorDictionary) {
		[[NSDistributedNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(_handleRemoteNotification:)
			name:name
			object:nil
			suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
		];
	}
}

+ (void)clientWantsToKnowThatTheServerIsAliveWithNotification:(NSNotification *)notif {
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/IAmAlive"
		object:notif.object
		userInfo:notif.userInfo
		deliverImmediately:YES
	];
}

+ (void)_handleRemoteNotification:(NSNotification *)notif { @synchronized (self) {
	_isRemoteNotification = YES;
	[self handleNotification:notif];
	_isRemoteNotification = NO;
}}

+ (void)handleNotification:(NSNotification *)notif { @synchronized (self) {
	NSString *selectorName = _selectorDictionary[notif.name];
	if (!selectorName) return;
	SEL selector = NSSelectorFromString(selectorName);
	((void(*)(Class,SEL,NSNotification *))
	(class_getMethodImplementation(objc_getMetaClass(class_getName(self)), selector)))
	(self, selector, notif);
}}

+ (void)terminateClient:(NSString *)bundleIdentifier exceptionName:(NSExceptionName)name message:(NSString *)message {
	if (_isRemoteNotification) [[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/Error"
		object:bundleIdentifier
		userInfo:@{ @"exceptionName" : name, @"exceptionMessage" : message }
		deliverImmediately:YES
	];
	else [NSException raise:name format:@"%@", message];
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
	NSLog(@"New lock owner: %@", _currentLockOwner);
	if (_isRemoteNotification) [[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/HeresYourLock"
		object:newOwnerData[0]
		userInfo:@{ @"completion" : newOwnerData[1] }
		deliverImmediately:YES
	];
	else {
		void(^block)(void) = (void(^)(void))(__bridge id)(void *)[newOwnerData[1] unsignedLongValue];
		if (block) {
			@try { block(); }
			@catch (NSException *ex) { [MMUserDefaults releaseLock]; @throw; }
		}
	}
}

+ (void)clientWantsToReleaseLockWithNotification:(NSNotification *)notif {
	if (![_currentLockOwner isEqualToString:notif.object]) {
		[self terminateClient:notif.object withNoLockErrorForSelector:_cmd];
		return;
	}
	NSLog(@"%@ has released its lock. The lock can now be acquired by something else.", _currentLockOwner);
	_currentLockOwner = nil;
	[self pickNewLockOwnerIfNecessary];
}

+ (void)clientWantsToAcquireLockWithNotification:(NSNotification *)notif {
	if (![notif.userInfo[@"completion"] isKindOfClass:[NSNumber class]] || !notif.object) return;
	[_lockQueue addObject:@[notif.object, notif.userInfo[@"completion"]]];
	[self pickNewLockOwnerIfNecessary];
}

+ (void)clientWantsToGetObjectWithNotification:(NSNotification *)notif {
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
		if (_isRemoteNotification) [[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.pixelomer.mobilemeadow/HeresYourData"
			object:notif.object
			userInfo:userInfo
			deliverImmediately:YES
		];
		else {
			void(^block)(id) = (void(^)(id))(__bridge id)(void *)[userInfo[@"completion"] unsignedLongValue];
			if (block) {
				@try { block(userInfo[@"data"]); }
				@catch (NSException *ex) { [MMUserDefaults releaseLock]; @throw; }
			}
		}
	}
}

+ (void)clientWantsToSetObjectWithNotification:(NSNotification *)notif {
	if (![_currentLockOwner isEqualToString:notif.object]) {
		[self terminateClient:notif.object withNoLockErrorForSelector:_cmd];
		return;
	}
	NSLog(@"The server will now set the value for key %@ to %@.", notif.userInfo[@"key"],notif.userInfo[@"object"]);
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
		if (_isRemoteNotification) [[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.pixelomer.mobilemeadow/SetObjectCompleted"
			object:notif.object
			userInfo:@{ @"completion" : notif.userInfo[@"completion"] }
			deliverImmediately:YES
		];
		else {
			void(^block)(void) = (void(^)(void))(__bridge id)(void *)[notif.userInfo[@"completion"] unsignedLongValue];
			if (block) {
				@try { block(); }
				@catch (NSException *ex) { [MMUserDefaults releaseLock]; @throw; }
			}
		}
	}
	NSMutableDictionary *dict = [NSMutableDictionary new];
	if (old) dict[@"old"] = old;
	if (notif.userInfo[@"object"]) dict[@"new"] = notif.userInfo[@"object"];
	dict[@"local"] = @NO;
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/ValueForKeyChanged"
		object:notif.userInfo[@"key"]
		userInfo:dict
		deliverImmediately:YES
	];
	dict[@"local"] = @YES;
	[[NSNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/ValueForKeyChanged"
		object:notif.userInfo[@"key"]
		userInfo:dict
	];
}

@end