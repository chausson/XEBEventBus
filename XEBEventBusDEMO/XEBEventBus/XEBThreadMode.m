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

#import "XEBThreadMode.h"

@interface XEBThreadMode() {
	NSString* _name;
}

- (instancetype)init __unavailable;

@end

#pragma mark -

@implementation XEBThreadMode

static XEBThreadMode* _postThread = nil;
static XEBThreadMode* _mainThread = nil;
static XEBThreadMode* _backgroundThread = nil;
static XEBThreadMode* _async = nil;

NSArray<XEBThreadMode*>* _values;

+ (void)initialize {
	if(self == [XEBThreadMode class]) {
		_values = @[
			_postThread = [[super alloc] initWithName: @"PostThread"],
			_mainThread = [[super alloc] initWithName: @"MainThread"],
			_backgroundThread = [[super alloc] initWithName: @"BackgroundThread"],
			_async = [[super alloc] initWithName: @"Async"],
		];
	}
}

+ (NSArray<XEBThreadMode*>*)values {
	return _values;
}

+ (instancetype)postThread {
	return _postThread;
}

+ (instancetype)mainThread {
	return _mainThread;
}

+ (instancetype)backgroundThread {
	return _backgroundThread;
}

+ (instancetype)async {
	return _async;
}

- (instancetype)initWithName: (NSString*)name {
	self = [super init];
	
	_name = name;
	
	return self;
}

@end
