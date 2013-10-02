## LabRAC

Experimental ReactiveCocoa signal operations. They've been used in an app, and
do have tests, but judge for yourself.

### Operations

* `-lab_replayLastWhen:`
* `-lab_combineLatest`
* `-lab_doFirst:`
* `-lab_doLast:`

##### `-lab_replayLastWhen:(RACSignal *)cue`

Returns a signal that passes through all values, while also resending the last
value on cue. Used to retrigger the last value on some event, such as the app
returning to the foreground.

##### `-lab_combineLatest`

Similar to `+combineLatest:`, except instead of combining the latest values
from a fixed collection of signals, this operation applies to a signal of
signals, combining the lastest values from each signal. For each signal sent,
the size of the "combination" increases by one. Unlike, `+combineLatest:`, the
resulting signal sends values of `NSArray`, not `RACTuple`.

##### `-lab_doFirst:(void (^)(id x))block`
##### `-lab_doLast:(void (^)(id x))block`

Similar to `-initially:` and `-finally:`, except the side effects represented by
these operators will only happen if the signal sends values.
