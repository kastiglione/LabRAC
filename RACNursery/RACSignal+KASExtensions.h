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

@end
