//
//  RACSignal+LabExtensions.m
//  LabRAC
//
//  Created by Dave Lee on 2013-09-20.
//  Copyright (c) 2013 Dave Lee. All rights reserved.
//

#import "RACSignal+LabExtensions.h"

@implementation RACSignal (LabExtensions)

- (RACSignal *)lab_replayLastWhen:(RACSignal *)cue {
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
		setNameWithFormat:@"[%@] -lab_replayLastWhen: %@", self.name, cue.name];
}

- (RACSignal *)lab_combineLatest {
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
		setNameWithFormat:@"%@ -lab_combineLatest", self.name];
}

- (RACSignal *)lab_doFirst:(void (^)(id x))block {
	return [[RACSignal
		createSignal:^(id<RACSubscriber> subscriber) {
			__block BOOL pending = YES;

			return [self subscribeNext:^(id x) {
				if (pending) {
					block(x);
					pending = NO;
				}

				[subscriber sendNext:x];
			} error:^(NSError *error) {
				[subscriber sendError:error];
			} completed:^{
				[subscriber sendCompleted];
			}];
		}]
		setNameWithFormat:@"[%@] -lab_doFirst:", self.name];
}

- (RACSignal *)lab_doLast:(void (^)(id x))block {
	return [[RACSignal
		createSignal:^(id<RACSubscriber> subscriber) {
			__block BOOL pending = NO;
			__block id last = nil;

			return [self subscribeNext:^(id x) {
				last = x;
				pending = YES;

				[subscriber sendNext:x];
			} error:^(NSError *error) {
				if (pending) {
					block(last);
				}

				[subscriber sendError:error];
			} completed:^{
				if (pending) {
					block(last);
				}

				[subscriber sendCompleted];
			}];
		}]
		setNameWithFormat:@"[%@] -lab_doLast:", self.name];
}

@end
