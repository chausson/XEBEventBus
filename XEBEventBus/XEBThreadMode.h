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

#import <Foundation/Foundation.h>

#define XEBThreadModePostThread [XEBThreadMode postThread]
#define XEBThreadModeMainThread [XEBThreadMode mainThread]
#define XEBThreadModeBackgroundThread [XEBThreadMode backgroundThread]
#define XEBThreadModeAsync [XEBThreadMode async]

@interface XEBThreadMode : NSObject

+ (instancetype _Nonnull)alloc __unavailable;

+ (NSArray<XEBThreadMode*>* _Nonnull)values;

+ (instancetype _Nonnull)postThread;
+ (instancetype _Nonnull)mainThread;
+ (instancetype _Nonnull)backgroundThread;
+ (instancetype _Nonnull)async;

@property(nonatomic, readonly, nonnull) NSString* name;

@end
