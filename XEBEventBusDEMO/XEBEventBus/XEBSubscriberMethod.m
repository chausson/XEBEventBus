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
#import "XEBSubscriberMethod.h"

#import "XEBThreadMode.h"

@interface XEBSubscriberMethod()

@end

#pragma mark -

@implementation XEBSubscriberMethod

- (instancetype)initWithSubscriberClass: (Class<XEBSubscriber>)subscriberClass selector: (SEL)selector threadMode: (XEBThreadMode*)threadMode eventClass: (Class)eventClass {
	self = [super init];
	
	_subscriberClass = subscriberClass;
	_selector = selector;
	_threadMode = threadMode;
	_eventClass = eventClass;
	
	return self;
}

- (NSUInteger)hash {
	NSUInteger hash = 0;
	hash ^= [NSStringFromClass(_subscriberClass) hash];
	hash ^= [NSStringFromSelector(_selector) hash];
	hash ^= [_threadMode hash];
	hash ^= [NSStringFromClass(_eventClass) hash];
	
	return hash;
}

- (BOOL)isEqual: (id)object {
	if([object isKindOfClass: [XEBSubscriberMethod class]]) {
		return [self isEqualToSubscriberMethod: (XEBSubscriberMethod*)object];
	}
	
	return FALSE;
}

- (BOOL)isEqualToSubscriberMethod: (XEBSubscriberMethod*)subscriberMethod {
	if(_subscriberClass != subscriberMethod->_subscriberClass) {
		return FALSE;
	}
	
	if(_selector != subscriberMethod->_selector) {
		return FALSE;
	}
	
	if(_threadMode != subscriberMethod->_threadMode) {
		return FALSE;
	}
	
	if(_eventClass != subscriberMethod->_eventClass) {
		return FALSE;
	}
	
	return TRUE;
}

@end
