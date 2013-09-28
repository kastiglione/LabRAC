//
//  RACSignal+KASExtensions.m
//  RACNursery
//
//  Created by Dave Lee on 2013-09-20.
//  Copyright (c) 2013 Dave Lee. All rights reserved.
//

#import "RACSignal+KASExtensions.h"

@implementation RACSignal (KASExtensions)

- (RACSignal *)kas_replayLastWhen:(RACSignal *)cue {
	NSCParameterAssert(cue != nil);

	return [[RACSignal
		createSignal:^(id<RACSubscriber> subscriber) {
			RACMulticastConnection *connection = [self publish];

			RACDisposable *mergeDisposable = [[RACSignal
				merge:@[ connection.signal, [connection.signal sample:cue] ]]
				subscribe:subscriber];

			RACDisposable *connectionDisposable = [connection connect];

			return [RACDisposable disposableWithBlock:^{
				[mergeDisposable dispose];
				[connectionDisposable dispose];
			}];
		}]
		setNameWithFormat:@"[%@] -kas_replayLastWhen: %@", self.name, cue.name];
}

- (RACSignal *)kas_combineLatest {
	return [[[self
		scanWithStart:[RACSignal return:[RACTuple new]] reduce:^(RACSignal *running, RACSignal *next) {
			return [[[running
				combineLatestWith:next]
				reduceEach:^(RACTuple *combined, id value) {
					return [combined tupleByAddingObject:value];
				}]
				replayLast];
		}]
		switchToLatest]
		setNameWithFormat:@"%@ -kas_combineLatest", self.name];
}

@end
