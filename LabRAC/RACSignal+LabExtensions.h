//
//  RACSignal+LabExtensions.h
//  LabRAC
//
//  Created by Dave Lee on 2013-09-20.
//  Copyright (c) 2013 Dave Lee. All rights reserved.
//

#import <ReactiveCocoa/ReactiveCocoa.h>

@interface RACSignal (LabExtensions)

/// Passes through all `next` values from the reciever. In addition, the most
/// recent `next` will be resent whenever `cue` sends a value.
///
/// See also -sample:
///
/// cue - The signal that controls when the latest value from the receiver
///       is resent. Cannot be nil.
///
/// Returns a signal that completes when the receiver completes.
- (RACSignal *)lab_replayLastWhen:(RACSignal *)cue;

/// Combines the latest values from signals sent by the receiver into NSArrays,
/// once signals have sent at least one `next`.
///
/// For each signal sent by the receiver, the output arrays corresondingly grow
/// by one value.
///
/// For each signal, additional `next`s will result in a new array sent with the
/// latest values from the current list of signals.
///
/// See also +combineLatest:
///
/// Returns a signal which sends NSArrays of the combined values, forwards any
/// `error` events, and completes when sent signals complete.
- (RACSignal *)lab_combineLatest;

/// Call the given block immediately prior to the first `next`. This should be
/// used to inject side effects into the signal.
- (RACSignal *)lab_doFirst:(void (^)(id x))block;

/// Call the given block after the last `next`, immediately prior to error or
/// completion. This should be used to inject side effects into the signal.
- (RACSignal *)lab_doLast:(void (^)(id x))block;

/// Execute the given block immediately prior to subscription of the receiver.
///
/// Counterpart to -lab_willSubscribe:
///
/// Identical to -initially:
- (RACSignal *)lab_willSubscribe:(void (^)(void))block;

/// Execute the given block immediately following subscription of the receiver.
///
/// Counterpart to -lab_willSubscribe:
- (RACSignal *)lab_didSubscribe:(void (^)(void))block;

@end
