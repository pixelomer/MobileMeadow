#import <Foundation/Foundation.h>

@interface MMUserDefaults : NSObject

// All of the methods here are thread-safe. Methods that require a lock will throw
// an exception if the process doesn't own the lock, and this exception cannot easily
// be caught using @catch since it is not thrown from the public methods below.

// Set object with a lock.
+ (void)setObject:(id)object forKey:(NSString *)key completion:(void(^)(void))completion;

// Get object with a lock.
+ (void)objectForKey:(NSString *)key completion:(void(^)(id))completion;

// Acquire a lock for objectForKey: and setObject:forKey:.
+ (void)acquireLockWithCompletion:(void(^)(void))completion;

// Get object for key without having to acquire a lock first.
+ (void)unlockedObjectForKey:(NSString *)key completion:(void(^)(id))completion;

// Use this to release a lock after acquiring it. This has to be done to free the lock
// so that it can be acquired by other processes. An exception will be thrown if the
// process doesn't own the lock. Do not call this outside of a completion block for
// acquireLockWithCompletion:, since it might cause another thread to lose its lock
// or it might cause an exception to be thrown since the process may not own the lock.
+ (void)releaseLock;

// Possible signatures:
//   handleValueChange
//   handleValueChangeForKey:(id)key
//   handleValueChangeForKey:(id)key fromValue:(id)old
//   handleValueChangeForKey:(id)key fromValue:(id)old toValue:(id)new
+ (void)addObserver:(id)observer forKey:(NSString *)key selector:(SEL)selector;

@end