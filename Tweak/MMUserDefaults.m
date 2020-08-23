#if ENABLE_MAIL_FUNCTIONALITY
#import "MMUserDefaults.h"
#import "MMUserDefaultsServer.h"

@implementation MMUserDefaults

static NSMutableArray *_retainArray;
static NSObject *_retainArrayLock;
static NSObject *_observerArrayLock;
static NSObject *_checkBlockArrayLock;
static NSPointerArray *_observers;
static NSMutableArray *_observerKeys;
static NSMutableArray *_observerSelectors;
static NSString *_uniqueObject;
static NSMutableArray *_newCheckBlocks;
static NSMutableArray *_oldCheckBlocks;

+ (void)heartbeat:(NSTimer *)timer {
	NSArray *olderCheckBlocks;
	@synchronized (_checkBlockArrayLock) {
		olderCheckBlocks = _oldCheckBlocks.copy;
		if (_newCheckBlocks.count) {
			_oldCheckBlocks = _newCheckBlocks.mutableCopy;
			_newCheckBlocks = [NSMutableArray new];
		}
		else {
			_oldCheckBlocks = nil;
		}
	}
	if (olderCheckBlocks.count) for (id completionObj in olderCheckBlocks) {
		void(^completion)(BOOL) = (void(^)(BOOL))completionObj;
		completion(NO);
	}
}

+ (void)postNotificationName:(NSNotificationName)name
	object:(NSString *)obj
	userInfo:(NSDictionary *)userInfo
{
	if ([MMUserDefaultsServer isCurrentProcessServer]) {
		[MMUserDefaultsServer handleNotification:[NSNotification
			notificationWithName:name
			object:obj
			userInfo:userInfo
		]];
	}
	else {
		[[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:name
			object:obj
			userInfo:userInfo
			deliverImmediately:YES
		];
	}
}

+ (void)load {
	if (self == [MMUserDefaults class]) {
		_retainArray = [NSMutableArray new];
		_retainArrayLock = [NSObject new];
		_observerArrayLock = [NSObject new];
		_observers = [NSPointerArray weakObjectsPointerArray];
		_observerKeys = [NSMutableArray new];
		_newCheckBlocks = [NSMutableArray new];
		_checkBlockArrayLock = [NSObject new];
		_observerSelectors = [NSMutableArray new];
		_uniqueObject = [NSString
			stringWithFormat:@"%u|%@",
			getpid(),
			[[NSBundle mainBundle] bundleIdentifier]
		];
		void(^block)(void) = ^{
			[[NSDistributedNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(didReceiveLockAcquisitionNotification:)
				name:@"com.pixelomer.mobilemeadow/HeresYourLock"
				object:_uniqueObject
				suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
			];
			[[NSDistributedNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(didReceiveObjectRetrievalNotification:)
				name:@"com.pixelomer.mobilemeadow/HeresYourData"
				object:_uniqueObject
				suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
			];
			[[NSDistributedNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(didReceiveSetObjectCompletionNotification:)
				name:@"com.pixelomer.mobilemeadow/SetObjectCompleted"
				object:_uniqueObject
				suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
			];
			[[NSDistributedNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(didReceiveHeartbeatNotification:)
				name:@"com.pixelomer.mobilemeadow/IAmAlive"
				object:_uniqueObject
				suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
			];
			[[NSDistributedNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(didReceiveErrorNotification:)
				name:@"com.pixelomer.mobilemeadow/Error"
				object:_uniqueObject
				suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
			];
			[[NSDistributedNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(didReceiveValueChangeNotification:)
				name:@"com.pixelomer.mobilemeadow/ValueForKeyChanged"
				object:nil
				suspensionBehavior:NSNotificationSuspensionBehaviorDeliverImmediately
			];
			[[NSNotificationCenter defaultCenter]
				addObserver:self
				selector:@selector(didReceiveValueChangeNotification:)
				name:@"com.pixelomer.mobilemeadow/ValueForKeyChanged"
				object:nil
			];
			NSTimer *timer = [NSTimer
				timerWithTimeInterval:1.0
				target:self
				selector:@selector(heartbeat:)
				userInfo:nil
				repeats:YES
			];
			[[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
		};
		// just in case, it might not be necessary idk
		if (![NSThread isMainThread]) dispatch_sync(dispatch_get_main_queue(), block);
		else block();
	}
}

+ (void)didReceiveHeartbeatNotification:(NSNotification *)notif {
	void(^completion)(BOOL) = (void(^)(BOOL))(__bridge id)(void *)[notif.userInfo[@"completion"] unsignedLongValue];
	@synchronized (_checkBlockArrayLock) {
		if ([_newCheckBlocks containsObject:(id)completion]) {
			[_newCheckBlocks removeObjectAtIndex:[_newCheckBlocks indexOfObject:(id)completion]];
		}
		else if ([_oldCheckBlocks containsObject:(id)completion]) {
			[_oldCheckBlocks removeObjectAtIndex:[_oldCheckBlocks indexOfObject:(id)completion]];
		}
		else return;
	}
	completion(YES);
}

+ (void)compactObserverArrays {
	for (NSInteger i=_observers.count-1; i>=0; i--) {
		if ([_observers pointerAtIndex:i]) continue;
		[_observers removePointerAtIndex:i];
		[_observerKeys removeObjectAtIndex:i];
		[_observerSelectors removeObjectAtIndex:i];
	}
}

+ (void)checkIfServerIsAliveWithCompletion:(void(^)(BOOL))completion {
	if (!completion) return;
	if ([MMUserDefaultsServer isCurrentProcessServer]) completion(YES);
	else {
		@synchronized (_checkBlockArrayLock) {
			[_newCheckBlocks addObject:(id)completion];
			completion = (void(^)(BOOL))_newCheckBlocks.lastObject;
		}
		[self
			postNotificationName:@"com.pixelomer.mobilemeadow/RespondIfAlive"
			object:_uniqueObject
			userInfo:@{ @"completion" : @((unsigned long)(__bridge void *)(id)completion) }
		];
	}
}

+ (void)addObserver:(id)observer forKey:(NSString *)key selector:(SEL)selector {
	if (key && ![key isKindOfClass:[NSString class]]) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"A string must be passed for the key argument. %@ is not a string.", key
		];
	}
	if (!observer) [NSException
		raise:NSInvalidArgumentException
		format:@"The observer must not be null."
	];
	if (!selector) [NSException
		raise:NSInvalidArgumentException
		format:@"The selector must not be null."
	];
	@synchronized (_observerArrayLock) {
		[self compactObserverArrays];
		[_observers addPointer:(__bridge void *)observer];
		[_observerKeys addObject:(key ?: [NSNull null])];
		[_observerSelectors addObject:NSStringFromSelector(selector)];
	}
}

+ (void)setObject:(id)object forKey:(NSString *)key completion:(void(^)(void))completion { @synchronized (_retainArrayLock) {
	if (completion) [_retainArray addObject:(id)completion];
	[self
		postNotificationName:@"com.pixelomer.mobilemeadow/SetObject"
		object:_uniqueObject
		userInfo:@{
			@"completion" : [NSNumber numberWithUnsignedLong:(completion ? (unsigned long)(__bridge void *)[_retainArray lastObject] : 0)],
			@"key" : key,
			@"object" : object
		}
	];
}}

+ (void)_objectForKey:(NSString *)key completion:(void(^)(id))completion noLock:(BOOL)noLock {
	if (!completion) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"Object retrieval completion block must not be null."
		];
	}
	if (![key isKindOfClass:[NSString class]]) {
		[NSException
			raise:NSInvalidArgumentException
			format:@"A string must be passed for the key argument. %@ is not a string.", key
		];
	}
	@synchronized (_retainArrayLock) {
		[_retainArray addObject:(id)completion];
		[self
			postNotificationName:@"com.pixelomer.mobilemeadow/GetObject"
			object:_uniqueObject
			userInfo:@{
				@"completion" : [NSNumber numberWithUnsignedLong:(unsigned long)(__bridge void *)[_retainArray lastObject]],
				@"key" : key,
				@"nolock" : @(noLock)
			}
		];
	}
}

+ (void)objectForKey:(NSString *)key completion:(void(^)(id))completion {
	[self _objectForKey:key completion:completion noLock:NO];
}

+ (void)_handleNotification:(NSNotification *)notif blockHandler:(void(^)(NSNotification *, id))block {
	unsigned long raw = [notif.userInfo[@"completion"] unsignedLongValue];
	void(^completion)() = (void(^)(id))(__bridge id)(void *)raw;
	if (completion) @synchronized (_retainArrayLock) {
		[_retainArray removeObject:(id)completion];
	}
	else return;
	@try { block(notif, completion); }
	@catch (NSException *ex) { [self releaseLock]; @throw; }
}

+ (void)didReceiveObjectRetrievalNotification:(NSNotification *)notif {
	[self _handleNotification:notif blockHandler:^(NSNotification *notif, void(^completion)(id)){
		completion(notif.userInfo[@"data"]);
	}];
}

+ (void)unlockedObjectForKey:(NSString *)key completion:(void(^)(id))completion {
	[self _objectForKey:key completion:completion noLock:YES];
}

+ (void)didReceiveSetObjectCompletionNotification:(NSNotification *)notif {
	[self _handleNotification:notif blockHandler:^(NSNotification *notif, void(^completion)(void)){
		completion();
	}];
}

+ (void)didReceiveLockAcquisitionNotification:(NSNotification *)notif {
	[self _handleNotification:notif blockHandler:^(NSNotification *notif, void(^completion)(void)){
		completion();
	}];
}

+ (void)acquireLockWithCompletion:(void(^)(void))completion { @synchronized (_retainArrayLock) {
	if (!completion) [NSException
		raise:NSInvalidArgumentException
		format:@"Lock acquisition completion block must not be null"
	];
	[_retainArray addObject:(id)completion];
	[self
		postNotificationName:@"com.pixelomer.mobilemeadow/AcquireLock"
		object:_uniqueObject
		userInfo:@{
			@"completion" : [NSNumber numberWithUnsignedLong:(unsigned long)(__bridge void *)[_retainArray lastObject]]
		}
	];
}}

+ (void)releaseLock {
	[self
		postNotificationName:@"com.pixelomer.mobilemeadow/ReleaseLock"
		object:_uniqueObject
		userInfo:nil
	];
}

+ (void)didReceiveErrorNotification:(NSNotification *)notif {
	[NSException
		raise:notif.userInfo[@"exceptionName"]
		format:@"%@", notif.userInfo[@"exceptionMessage"]
	];
}

+ (void)didReceiveValueChangeNotification:(NSNotification *)notif { @synchronized (_observerArrayLock) {
	if ([MMUserDefaultsServer isCurrentProcessServer] && ![notif.userInfo[@"local"] boolValue]) {
		return;
	}
	[self compactObserverArrays];
	for (NSUInteger i=0; i<_observerKeys.count; i++) {
		NSString *currentKey = _observerKeys[i];
		if ([currentKey isKindOfClass:[NSNull class]]) currentKey = nil;
		if (!currentKey || [currentKey isEqualToString:notif.object]) { @autoreleasepool {
			id target = (__bridge id)[_observers pointerAtIndex:i];
			if (!target) continue;
			SEL selector = NSSelectorFromString(_observerSelectors[i]);
			NSMethodSignature *sig = [target methodSignatureForSelector:selector];
			if (!sig) continue;
			NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sig];
			inv.selector = selector;
			inv.target = target;
			NSString *arg = notif.object;
			if (sig.numberOfArguments >= 3) [inv setArgument:&arg atIndex:2];
			arg = notif.userInfo[@"old"];
			if (sig.numberOfArguments >= 4) [inv setArgument:&arg atIndex:3];
			arg = notif.userInfo[@"new"];
			if (sig.numberOfArguments >= 5) [inv setArgument:&arg atIndex:4];
			[inv invoke];
		}}
	}
}}

@end
#endif