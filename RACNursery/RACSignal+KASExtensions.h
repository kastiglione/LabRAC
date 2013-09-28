//
//  RACSignal+KASExtensions.h
//  RACNursery
//
//  Created by Dave Lee on 2013-09-20.
//  Copyright (c) 2013 Dave Lee. All rights reserved.
//

@interface RACSignal (KASExtensions)

/// Passes through all `next` values from the reciever. In addition, the most
/// recent `next` will be resent whenever `cue` sends a value.
///
/// See also -sample:
///
/// cue - The signal that controls when the latest value from the receiver
///       is resent. Cannot be nil.
///
/// Returns a signal that completes when the receiver completes.
- (RACSignal *)kas_replayLastWhen:(RACSignal *)cue;

/// Combines the latest values from signals sent by the receiver into RACTuples,
/// once signals have sent at least one `next`.
///
/// For each signal sent by the receiver, the output tuples corresondingly grow
/// by one value.
///
/// For each signal, additional `next`s will result in a new RACTuple with the
/// latest values from the current list of signals.
///
/// See also +combineLatest:
///
/// Returns a signal which sends RACTuples of the combined values, forwards any
/// `error` events, and completes when sent signals complete.
- (RACSignal *)kas_combineLatest;

@end
