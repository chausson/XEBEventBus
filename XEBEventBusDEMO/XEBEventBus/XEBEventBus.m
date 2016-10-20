/*
 * Copyright (C) 2015 Chausson
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "XEBEventBus.h"

#import "XEBPostingThreadState.h"
#import "XEBSubscriberMethod.h"
#import "XEBSubscriberMethodFinder.h"
#import "XEBSubscription.h"
#import "XEBThreadLocal.h"
#import "XEBThreadMode.h"

#define TAG @"event"

#pragma mark -

@interface XEBEventBus() {
	NSMutableDictionary<NSString*, NSMutableArray<XEBSubscription*>*>* _subscriptionsByEventClassName;
	NSMutableDictionary<NSValue*, NSMutableArray<Class>*>* _eventClassesBySubscriber;
	
	XEBThreadLocal<XEBPostingThreadState*>* _currentPostingThreadState;

	XEBSubscriberMethodFinder* _subscriberMethodFinder;
}

@end

#pragma mark -

@implementation XEBEventBus

static NSMutableDictionary<NSString*, NSMutableArray<Class>*>* _eventClassesCache;

+ (void)initialize {
	if(self != [XEBEventBus class]) {
		return;
	}
	
	_eventClassesCache = [[NSMutableDictionary alloc] init];
}

static XEBEventBus* _defaultInstance;

+ (instancetype)defaultEventBus {
	if(_defaultInstance == nil) {
		@synchronized([XEBEventBus class]) {
			if(_defaultInstance == nil) {
				_defaultInstance = [[XEBEventBus alloc] init];
			}
		}
	}
	
	return _defaultInstance;
}

- (instancetype)init {
	self = [super init];
	
	_subscriptionsByEventClassName = [[NSMutableDictionary alloc] init];
	_eventClassesBySubscriber = [[NSMutableDictionary alloc] init];
	
	_currentPostingThreadState = [[XEBThreadLocal alloc] initWithInitialValueBlock: ^XEBPostingThreadState* {
		XEBPostingThreadState* postingThreadState  = [[XEBPostingThreadState alloc] init];
		
		return postingThreadState;
	}];
	
	_subscriberMethodFinder = [[XEBSubscriberMethodFinder alloc] init];
	
	return self;
}

- (void)registerSubscriber: (NSObject<XEBSubscriber>*)subscriber {
	[self registerSubscriber: subscriber sticky: false priority: 0];
}

- (void)registerSubscriber: (NSObject<XEBSubscriber>*)subscriber priority: (NSInteger)priority {
	[self registerSubscriber: subscriber sticky: false priority: priority];
}

- (void)registerStickySubscriber: (NSObject<XEBSubscriber>*)subscriber {
	[self registerSubscriber: subscriber sticky: true priority: 0];
}

- (void)registerStickySubscriber: (NSObject<XEBSubscriber>*)subscriber priority: (NSInteger)priority {
	[self registerSubscriber: subscriber sticky: true priority: priority];
}

- (void)registerSubscriber: (NSObject<XEBSubscriber>*)subscriber sticky: (BOOL)sticky priority: (NSInteger)priority {
	@synchronized(self) {
		NSArray<XEBSubscriberMethod*>* subscriberMethods = [_subscriberMethodFinder findSubscriberMethods: [subscriber class]];
		for(XEBSubscriberMethod* subscriberMethod in subscriberMethods) {
			[self subscribe: subscriber subscriberMethod: subscriberMethod sticky: sticky priority: priority];
		}
	}
}

/**
 * @warning Must be called in synchronized block.
 */
- (void)subscribe: (NSObject<XEBSubscriber>*)subscriber subscriberMethod: (XEBSubscriberMethod*)subscriberMethod sticky: (BOOL)sticky priority: (NSInteger)priority {
	Class eventClass = [subscriberMethod eventClass];
	NSString* eventClassName = NSStringFromClass(eventClass);
	
	NSMutableArray<XEBSubscription*>* subscriptions = _subscriptionsByEventClassName[eventClassName];
	
	XEBSubscription* subscription = [[XEBSubscription alloc] initWithSubscriber: subscriber subscriberMethod: subscriberMethod priority: priority];
	if(subscriptions == nil) {
		subscriptions = [[NSMutableArray alloc] init];
		_subscriptionsByEventClassName[eventClassName] = subscriptions;
	}
	else {
		if([subscriptions containsObject: subscription]) {
			// TODO Raise an exception.
		}
	}
	
	NSInteger count = [subscriptions count];
	NSInteger index;
	for(index = 0; index < count; index++) {
		if(subscription.priority > subscriptions[index].priority) {
			break;
		}
	}
	[subscriptions insertObject: subscription atIndex: index];
	
	NSValue* subscriberKey = [NSValue valueWithNonretainedObject: subscriber];
	NSMutableArray<Class>* subscribedEventClasses = _eventClassesBySubscriber[subscriberKey];
	if(subscribedEventClasses == nil) {
		subscribedEventClasses = [[NSMutableArray alloc] init];
		_eventClassesBySubscriber[subscriberKey] = subscribedEventClasses;
	}
	[subscribedEventClasses addObject: eventClass];
	
	if(sticky) {
		// TODO Deal with sticky events.
	}
}

- (BOOL)isRegisteredSubscriber: (NSObject<XEBSubscriber>*)subscriber {
	@synchronized(self) {
		NSValue* subscriberKey = [NSValue valueWithNonretainedObject: subscriber];
		BOOL registered = (_eventClassesBySubscriber[subscriberKey] != nil);
		
		return registered;
	}
}

/**
 * @warning Only updates <code>_subscriptionsByEventClassName</code>, not <code>_eventClassesBySubscriber</code>! Caller must update <code>_eventClassesBySubscriber</code>.
 */
- (void)unsubscribe: (NSObject<XEBSubscriber>*)subscriber byEventClass: (Class)eventClass {
	NSString* eventClassName = NSStringFromClass(eventClass);
	NSMutableArray<XEBSubscription*>* subscriptions = _subscriptionsByEventClassName[eventClassName];
	if(subscriptions != nil) {
		NSInteger count = [subscriptions count];
		for(NSInteger i = count - 1; i >= 0; i--) {
			XEBSubscription* subscription = subscriptions[i];
			if(subscription.subscriber == subscriber) {
				subscription.active = FALSE;
				[subscriptions removeObject: subscription];
			}
		}
	}
}

- (void)unregisterSubscriber: (NSObject<XEBSubscriber>*)subscriber {
	@synchronized(self) {
		NSValue* subscriberKey = [NSValue valueWithNonretainedObject: subscriber];
		NSMutableArray<Class>* eventClasses = _eventClassesBySubscriber[subscriberKey];
		if(eventClasses != nil) {
			for(Class eventClass in eventClasses) {
				[self unsubscribe: subscriber byEventClass: eventClass];
			}
			[_eventClassesBySubscriber removeObjectForKey: subscriberKey];
		}
		else {
			NSLog(@"[%@]Subscriber to unregister was not registered before: %@.", TAG, NSStringFromClass([subscriber class]));
		}
	}
}

- (void)postEvent: (NSObject*)event {
	XEBPostingThreadState* postingState = [_currentPostingThreadState value];
	NSMutableArray<NSObject*>* eventQueue = [postingState eventQueue];
	[eventQueue addObject: event];
	
	if(!postingState.isPosting) {
		postingState.isMainThread = [NSThread isMainThread];
		postingState.isPosting = TRUE;
		
		if(postingState.isCanceled) {
			[NSException raise: NSInternalInconsistencyException format: @"Internal error. Abort state was not reset."];
		}
		
		@try {
			while([eventQueue count] != 0) {
				NSObject* event = eventQueue[0];
				[eventQueue removeObjectAtIndex: 0];
				
				[self postSingleEvent: event postingState: postingState];
			}
		}
		@finally {
			postingState.isPosting = FALSE;
			postingState.isMainThread = FALSE;
		}
	}
}

- (void)cancelEventDelivery: (NSObject*)event {
	XEBPostingThreadState* postingState = [_currentPostingThreadState value];
	if(!postingState.isPosting) {
		[NSException raise: NSInternalInconsistencyException format: @"This method may only be called from inside event handling methods on the posting thread."];
	}
	
	if (postingState.event != event) {
		[NSException raise: NSInvalidArgumentException format: @"Only the currently handled event may be aborted."];
	}
	
	if(postingState.subscription.subscriberMethod.threadMode != XEBThreadModePostThread) {
		[NSException raise: NSInvalidArgumentException format: @"Event handlers may only abort the incoming event."];
	}

	postingState.canceled = true;
}

- (void)postStickyEvent: (NSObject*)event {
	// TODO
}

- (BOOL)hasSubscriberForEventClass: (Class)eventClass {
	NSArray<Class>* eventClasses = [self lookupAllEventClasses: eventClass];
	if(eventClasses != nil) {
		for(Class clazz in eventClasses) {
			NSString* className = NSStringFromClass(clazz);
			
			NSMutableArray<XEBSubscription*>* subscriptions;
			@synchronized(self ) {
				subscriptions = _subscriptionsByEventClassName[className];
			}
			
			if([subscriptions count] != 0) {
				return TRUE;
			}
		}
	}
	
	return FALSE;
}

- (void)postSingleEvent: (NSObject*)event postingState: (XEBPostingThreadState*)postingState {
	Class eventClass = [event class];
	BOOL subscriptionFound = FALSE;
	
	NSArray<Class>* eventClasses = [self lookupAllEventClasses: eventClass];
	for(Class eventClass in eventClasses) {
		subscriptionFound |= [self postSingleEvent: event postingState: postingState eventClass: eventClass];
	}
	
	if(!subscriptionFound) {
		NSLog(@"[%@]No subscribers registered for event %@.", TAG, NSStringFromClass(eventClass));
	}
}

- (BOOL)postSingleEvent: (NSObject*)event postingState: (XEBPostingThreadState*)postingState eventClass: (Class)eventClass {
	NSString* eventClassName = NSStringFromClass(eventClass);
	
	NSMutableArray* subscriptions;
	@synchronized(self) {
		subscriptions = [_subscriptionsByEventClassName[eventClassName] copy];
	}
	
	if([subscriptions count] != 0) {
		for(XEBSubscription* subscription in subscriptions) {
			postingState.event = event;
			postingState.subscription = subscription;
			BOOL aborted = FALSE;
			
			@try {
				[self postToSubscription: subscription event: event isMainThread: postingState.isMainThread];
				aborted = postingState.canceled;
			}
			@finally {
				postingState.event = nil;
				postingState.subscription = nil;
				postingState.canceled = FALSE;
			}
			
			if(aborted) {
				break;
			}
		}
		
		return TRUE;
	}
	
	return FALSE;
}

- (void)postToSubscription: (XEBSubscription*)subscription event: (NSObject*)event isMainThread: (BOOL)isMainThread {
	XEBThreadMode* threadMode = subscription.subscriberMethod.threadMode;
	if(threadMode == XEBThreadModePostThread) {
		[self invokeSubscriberWithSubscription: subscription event: event];
	}
	else if(threadMode == XEBThreadModeMainThread) {
		if(isMainThread) {
			[self invokeSubscriberWithSubscription: subscription event: event];
		}
		else {
			dispatch_queue_t mainQueue = dispatch_get_main_queue();
			dispatch_async(mainQueue, ^ {
				[self invokeSubscriberWithSubscription: subscription event: event];
			});
		}
	}
	else if(threadMode == XEBThreadModeBackgroundThread) {
		if(isMainThread) {
			dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
			dispatch_async(backgroundQueue, ^ {
				[self invokeSubscriberWithSubscription: subscription event: event];
			});
		}
		else {
			[self invokeSubscriberWithSubscription: subscription event: event];
		}
	}
	else if(threadMode == XEBThreadModeAsync) {
		if(isMainThread) {
			dispatch_queue_t mainQueue = dispatch_get_main_queue();
			dispatch_async(mainQueue, ^ {
				[self invokeSubscriberWithSubscription: subscription event: event];
			});
		}
		else {
			dispatch_queue_t backgroundQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
			dispatch_async(backgroundQueue, ^ {
				[self invokeSubscriberWithSubscription: subscription event: event];
			});
		}
	}
}

- (NSMutableArray<Class>*)lookupAllEventClasses: (Class)eventClass {
	@synchronized(_eventClassesCache) {
		NSString* eventClassName = NSStringFromClass(eventClass);
		
		NSMutableArray* eventClasses = _eventClassesCache[eventClassName];
		if(eventClasses == nil) {
			eventClasses = [[NSMutableArray alloc] init];
			Class clazz = eventClass;
			while(clazz != nil) {
				[eventClasses addObject: clazz];
				clazz = [clazz superclass];
			}
			_eventClassesCache[eventClassName] = eventClasses;
		}
		
		return eventClasses;
	}
}

- (void)invokeSubscriberWithSubscription: (XEBSubscription*)subscription event: (NSObject*)event {
	@try {
		NSObject<XEBSubscriber>* subscriber = subscription.subscriber;
		SEL selector = subscription.subscriberMethod.selector;
		
		NSInvocation* invocation = [NSInvocation invocationWithMethodSignature: [subscriber methodSignatureForSelector: selector]];
		[invocation setTarget: subscriber];
		[invocation setSelector: selector];
		[invocation setArgument: &event atIndex: 2];
		[invocation retainArguments];
		[invocation invoke];
	}
	@catch(NSException* e) {
		// TODO
		@throw e;
	}
}

@end
