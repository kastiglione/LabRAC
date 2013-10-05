//
//  RACSignalLabExtensionsSpec.m
//  LabRAC
//
//  Created by Dave Lee on 2013-09-20.
//  Copyright (c) 2013 Dave Lee. All rights reserved.
//

#import "LabRAC.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

#define EXP_SHORTHAND
#import "Specta.h"
#import "Expecta.h"

SpecBegin(RACSignalLabExtensionsSpec)

describe(@"-lab_replayLastWhen:", ^{
	__block RACSubject *subject;
	__block RACSubject *cue;
	__block RACSignal *replayer;

	beforeEach(^{
		subject = [RACSubject subject];
		cue = [RACSubject subject];
		replayer = [subject lab_replayLastWhen:cue];
	});

	it(@"should send the latest value", ^{
		__block id latest;
		[replayer subscribeNext:^(id x) {
			latest = x;
		}];
		expect(latest).to.beNil();

		[subject sendNext:@23];
		expect(latest).to.equal(@23);
	});

	it(@"should resend the most recent value when cued", ^{
		NSMutableArray *values = [NSMutableArray array];
		NSArray *expected;

		[replayer subscribeNext:^(id x) {
			[values addObject:x];
		}];
		expected = @[];
		expect(values).to.equal(expected);

		[subject sendNext:@23];
		expected = @[ @23 ];
		expect(values).to.equal(expected);

		[cue sendNext:RACUnit.defaultUnit];
		expected = @[ @23, @23 ];
		expect(values).to.equal(expected);
	});

	it(@"should complete when source signal completes", ^{
		__block BOOL completed = NO;
		[replayer subscribeCompleted:^{
			completed = YES;
		}];
		expect(completed).to.beFalsy();

		[subject sendCompleted];
		expect(completed).to.beTruthy();
	});
});

describe(@"-lab_combineLatest:", ^{
	__block RACSubject *subject;
	__block RACSignal *combined;

	beforeEach(^{
		subject = [RACSubject subject];
		combined = [subject lab_combineLatest];
	});

	it(@"should combine latest from incoming signals", ^{
		__block NSArray *latest;
		[combined subscribeNext:^(NSArray *x) {
			latest = x;
		}];
		expect(latest).to.equal(nil);

		RACSubject *first = [RACSubject subject];
		[subject sendNext:first];
		expect(latest).to.equal(nil);

		[first sendNext:@1];
		expect(latest).to.equal(@[ @1 ]);

		[first sendNext:@2];
		expect(latest).to.equal(@[ @2 ]);

		[subject sendNext:[RACSignal return:@3]];
		expect(latest).to.equal((@[ @2, @3 ]));
	});
});

describe(@"-lab_doFirst:", ^{
	__block RACSubject *subject;
	__block BOOL blockCalled;
	__block id firstValue;

	beforeEach(^{
		subject = [RACSubject subject];
		blockCalled = NO;
		firstValue = nil;

		[[[subject
			lab_doFirst:^(id x) {
				blockCalled = YES;
				firstValue = x;
			}]
			publish]
			connect];
	});

	it(@"should not call block for empty signals", ^{
		[subject sendCompleted];
		expect(blockCalled).to.beFalsy();
	});

	it(@"should call block for first value", ^{
		[subject sendNext:@1];
		expect(firstValue).to.equal(@1);

		[subject sendNext:@2];
		expect(firstValue).to.equal(@1);
	});
});

describe(@"-lab_doLast:", ^{
	__block RACSubject *subject;
	__block BOOL blockCalled;
	__block id lastValue;

	beforeEach(^{
		subject = [RACSubject subject];
		blockCalled = NO;
		lastValue = nil;

		[[[subject
			lab_doLast:^(id x) {
				blockCalled = YES;
				lastValue = x;
			}]
			publish]
			connect];
	});

	it(@"should not call block for empty signals", ^{
		[subject sendCompleted];
		expect(blockCalled).to.beFalsy();
	});

	it(@"should call block for last value before completion", ^{
		[subject sendNext:@1];
		expect(blockCalled).to.beFalsy();

		[subject sendNext:@2];
		expect(blockCalled).to.beFalsy();

		[subject sendCompleted];
		expect(lastValue).to.equal(@2);
	});

	it(@"should call block for last value before error", ^{
		[subject sendNext:@1];
		expect(blockCalled).to.beFalsy();

		[subject sendNext:@2];
		expect(blockCalled).to.beFalsy();

		[subject sendError:[NSError new]];
		expect(lastValue).to.equal(@2);
	});
});

describe(@"-lab_willSubscribe:", ^{
	it(@"should perform side effects before subscription", ^{
		__block BOOL hasSubscribed = NO;
		RACSignal *signal = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
			hasSubscribed = YES;
			return nil;
		}];

		[[[signal
			lab_willSubscribe:^{
				expect(hasSubscribed).to.beFalsy();
			}]
			publish]
			connect];
		expect(hasSubscribed).to.beTruthy();
	});
});

describe(@"-lab_didSubscribe:", ^{
	it(@"should perform side effects after subscription", ^{
		__block BOOL hasSubscribed = NO;
		RACSignal *signal = [RACSignal createSignal:^ RACDisposable * (id<RACSubscriber> subscriber) {
			hasSubscribed = YES;
			return nil;
		}];

		expect(hasSubscribed).to.beFalsy();
		[signal lab_didSubscribe:^{
			expect(hasSubscribed).to.beTruthy();
		}];
	});
});

SpecEnd
