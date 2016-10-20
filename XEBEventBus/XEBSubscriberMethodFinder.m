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

#import "XEBSubscriberMethodFinder.h"

#import "XEBSubscriber.h"
#import "XEBSubscriberMethod.h"
#import "XEBThreadMode.h"

#define ON_EVENT_SELECTOR_NAME_PATTERN @"onEvent%@:"

#pragma mark -

@interface XEBSubscriberMethodFinder() {
}

@end

#pragma mark -

@implementation XEBSubscriberMethodFinder

static NSDictionary<NSString*, XEBThreadMode*>* _threadModesForModifiers;

static NSMutableDictionary<NSString*, NSArray<XEBSubscriberMethod*>*>* _methodCache;

+ (void)initialize {
	if(self != [XEBSubscriberMethodFinder class]) {
		return;
	}
	
	_threadModesForModifiers = @{
		@"": XEBThreadModePostThread,
		@"MainThread": XEBThreadModeMainThread,
		@"BackgroundThread": XEBThreadModeBackgroundThread,
		@"Async": XEBThreadModeAsync,
	};
	
	_methodCache = [[NSMutableDictionary alloc] init];
}

- (NSArray<XEBSubscriberMethod*>*)findSubscriberMethods: (Class<XEBSubscriber>)subscriberClass {
	NSArray<XEBSubscriberMethod*>* subscriberMethods = nil;
	
	NSString* cacheKey = NSStringFromClass(subscriberClass);
	
	@synchronized(_methodCache) {
		subscriberMethods = [_methodCache objectForKey: cacheKey];
	}
	
	if(subscriberMethods != nil) {
		return subscriberMethods;
	}
	
	subscriberMethods = ^NSArray* {;
		NSMutableArray* subscriberMethods = [[NSMutableArray alloc] init];
		
		NSArray* supportedEventClasses = [subscriberClass handleableEventClasses];
		
		for(NSString* modifier in [_threadModesForModifiers allKeys]) {
			NSString* selectorName = [[NSString alloc] initWithFormat: ON_EVENT_SELECTOR_NAME_PATTERN, modifier];
			SEL selector = NSSelectorFromString(selectorName);
			
			if([subscriberClass.self instancesRespondToSelector: selector]) {
				XEBThreadMode* threadMode = [_threadModesForModifiers objectForKey: modifier];
				
				for(Class eventClass in supportedEventClasses) {
					XEBSubscriberMethod* subscriberMethod = [[XEBSubscriberMethod alloc] initWithSubscriberClass: subscriberClass selector: selector threadMode: threadMode eventClass: eventClass];
					[subscriberMethods addObject: subscriberMethod];
				}
			}
		}
		
		return [subscriberMethods copy];
	} ();
	
	@synchronized(_methodCache) {
		[_methodCache setObject: subscriberMethods forKey: cacheKey];
	}
	
	return subscriberMethods;
}

@end
