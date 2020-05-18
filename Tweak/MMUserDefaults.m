#import "MMUserDefaults.h"

@implementation MMUserDefaults

static NSMutableArray *_retainArray;
static NSObject *_retainArrayLock;
static NSObject *_observerArrayLock;
static NSPointerArray *_observers;
static NSMutableArray *_observerKeys;
static NSMutableArray *_observerSelectors;
static NSString *_uniqueObject;

+ (void)load {
	if (self == [MMUserDefaults class]) {
		_retainArray = [NSMutableArray new];
		_retainArrayLock = [NSObject new];
		_observerArrayLock = [NSObject new];
		_observers = [NSPointerArray weakObjectsPointerArray];
		_observerKeys = [NSMutableArray new];
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
		};
		// just in case, it might not be necessary idk
		if (![NSThread isMainThread]) dispatch_sync(dispatch_get_main_queue(), block);
		else block();
	}
}

+ (void)compactObserverArrays {
	for (NSInteger i=_observers.count-1; i>=0; i--) {
		if ([_observers pointerAtIndex:i]) continue;
		[_observers removePointerAtIndex:i];
		[_observerKeys removeObjectAtIndex:i];
		[_observerSelectors removeObjectAtIndex:i];
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
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/SetObject"
		object:_uniqueObject
		userInfo:@{
			@"completion" : [NSNumber numberWithUnsignedLong:(completion ? (unsigned long)(__bridge void *)[_retainArray lastObject] : 0)],
			@"key" : key,
			@"object" : object
		}
		deliverImmediately:YES
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
		[[NSDistributedNotificationCenter defaultCenter]
			postNotificationName:@"com.pixelomer.mobilemeadow/GetObject"
			object:_uniqueObject
			userInfo:@{
				@"completion" : [NSNumber numberWithUnsignedLong:(unsigned long)(__bridge void *)[_retainArray lastObject]],
				@"key" : key,
				@"nolock" : @(noLock)
			}
			deliverImmediately:YES
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
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/AcquireLock"
		object:_uniqueObject
		userInfo:@{
			@"completion" : [NSNumber numberWithUnsignedLong:(unsigned long)(__bridge void *)[_retainArray lastObject]]
		}
		deliverImmediately:YES
	];
}}

+ (void)releaseLock {
	[[NSDistributedNotificationCenter defaultCenter]
		postNotificationName:@"com.pixelomer.mobilemeadow/ReleaseLock"
		object:_uniqueObject
		userInfo:nil
		deliverImmediately:YES
	];
}

+ (void)didReceiveErrorNotification:(NSNotification *)notif {
	[NSException
		raise:notif.userInfo[@"exceptionName"]
		format:@"%@", notif.userInfo[@"exceptionMessage"]
	];
}

+ (void)didReceiveValueChangeNotification:(NSNotification *)notif { @synchronized (_observerArrayLock) {
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