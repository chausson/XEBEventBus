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

@class XEBSubscriberMethod;
@protocol XEBSubscriber;

@interface XEBSubscription : NSObject

- (instancetype _Nonnull)init __unavailable;
- (instancetype _Nonnull)initWithSubscriber: (NSObject<XEBSubscriber>* _Nonnull)subscriber subscriberMethod: (XEBSubscriberMethod* _Nonnull)subscriberMethod priority: (NSInteger)priority NS_DESIGNATED_INITIALIZER;

@property(nonatomic, assign, readonly, nonnull) NSObject<XEBSubscriber>* subscriber;
@property(nonatomic, readonly, nonnull) XEBSubscriberMethod* subscriberMethod;
@property(nonatomic, readonly) NSInteger priority;

@property(nonatomic) BOOL active;

@end
