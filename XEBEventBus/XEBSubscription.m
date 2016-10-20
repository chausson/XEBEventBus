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

#import "XEBSubscription.h"

#import "XEBSubscriberMethod.h"

@implementation XEBSubscription

- (instancetype)initWithSubscriber: (NSObject<XEBSubscriber>*)subscriber subscriberMethod: (XEBSubscriberMethod*)subscriberMethod priority: (NSInteger)priority {
	self = [super init];
	
	_subscriber = subscriber;
	_subscriberMethod = subscriberMethod;
	_priority = priority;
	
	_active = TRUE;
	
	return self;
}

- (BOOL)isEqual: (id)other {
	if(![other isKindOfClass: [XEBSubscription class]]) {
		return FALSE;
	}
	
	return [self isEqualToSubscription: other];
}

- (BOOL)isEqualToSubscription: (XEBSubscription*)other {
	if(_subscriber != other->_subscriber) {
		return FALSE;
	}
	
	if(![_subscriberMethod isEqual: other->_subscriberMethod]) {
		return FALSE;
	}
	
	if(_priority != other->_priority) {
		return FALSE;
	}
	
	return TRUE;
}

- (NSUInteger)hash {
	NSUInteger hash = 0;
	hash ^= [_subscriber hash];
	hash ^= [_subscriberMethod hash];
	hash ^= _priority;
	
	return hash;
}

@end
