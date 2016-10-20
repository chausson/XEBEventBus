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

#import "XEBThreadLocal.h"

@interface XEBThreadLocal<T>() {
	T (^_initialValueBlock)();
	
	NSMutableDictionary<NSValue*, T>* _valuesAgainstThreadPointer;
	
	NSObject* _nullValue;
}

@end

#pragma mark -

@implementation XEBThreadLocal

- (instancetype)init {
	return [self initWithInitialValueBlock: NULL];
}

- (instancetype)initWithInitialValueBlock: (id _Nullable (^)())initialValueBlock {
	self = [super init];
	
	_initialValueBlock = initialValueBlock;
	_valuesAgainstThreadPointer = [[NSMutableDictionary alloc] init];
	_nullValue = [[NSObject alloc] init];
	
	[[NSNotificationCenter defaultCenter] addObserverForName: NSThreadWillExitNotification object: nil queue: nil usingBlock: ^(NSNotification* notification) {
		NSThread* thread = [notification object];
		NSValue* threadPointer = [NSValue valueWithNonretainedObject: thread];
		[_valuesAgainstThreadPointer removeObjectForKey: threadPointer];
	}];
	
	return self;
}

- (void)dealloc {
	[[NSNotificationCenter defaultCenter] removeObserver: self];
}

- (id)value {
	NSThread* thread = [NSThread currentThread];
	NSValue* threadPointer = [NSValue valueWithNonretainedObject: thread];
	
	id value = _valuesAgainstThreadPointer[threadPointer];
	
	if(value == nil) {
		if(_initialValueBlock != NULL) {
			value = _initialValueBlock();
		}
		
		_valuesAgainstThreadPointer[threadPointer] = (value == nil ? _nullValue : value);
	}
	else if(value == _nullValue) {
		value = nil;
	}
	
	return value;
}

- (void)setValue: (id)value {
	NSThread* thread = [NSThread currentThread];
	NSValue* threadPointer = [NSValue valueWithNonretainedObject: thread];
	_valuesAgainstThreadPointer[threadPointer] = (value == nil ? _nullValue : value);
}

- (void)removeValue {
	NSThread* thread = [NSThread currentThread];
	NSValue* threadPointer = [NSValue valueWithNonretainedObject: thread];
	[_valuesAgainstThreadPointer removeObjectForKey: threadPointer];
}

@end
