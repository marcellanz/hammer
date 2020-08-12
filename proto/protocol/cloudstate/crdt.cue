// Copyright 2019 Lightbend Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// gRPC interface for Event Sourced Entity user functions.
package protocol

import "googleapis.com/cloudstate:protocol"

// Message for the Crdt handle stream in.
#CrdtStreamIn: {
	{} | {
		// Always sent first, and only once.
		init: #CrdtInit @protobuf(1)
	} | {
		// Sent to indicate the user function should replace its current state with this state. If the user function
		// does not have a current state, either because the init function didn't send one and the user function hasn't
		// updated the state itself in response to a command, or because the state was deleted, this must be sent before
		// any deltas.
		state: #CrdtState @protobuf(2)
	} | {
		// A delta to be applied to the current state. May be sent at any time as long as the user function already has
		// state.
		changed: #CrdtDelta @protobuf(3)
	} | {
		// Delete the entity. May be sent at any time. The user function should clear its state when it receives this.
		// A proxy may decide to terminate the stream after sending this.
		deleted: #CrdtDelete @protobuf(4)
	} | {
		// A command, may be sent at any time.
		command: protocol.#Command @protobuf(5,type=Command)
	} | {
		// A stream has been cancelled.
		streamCancelled: protocol.#StreamCancelled @protobuf(6,type=StreamCancelled,name=stream_cancelled)
	}
}

// Message for the Crdt handle stream out.
#CrdtStreamOut: {
	{} | {
		// A reply to an incoming command. Either one reply, or one failure, must be sent in response to each command.
		reply: #CrdtReply @protobuf(1)
	} | {
		// A streamed message.
		streamedMessage: #CrdtStreamedMessage @protobuf(2,name=streamed_message)
	} | {
		// A stream cancelled response, may be sent in response to stream_cancelled.
		streamCancelledResponse: #CrdtStreamCancelledResponse @protobuf(3,name=stream_cancelled_response)
	} | {
		// A failure. Either sent in response to a command, or sent if some other error occurs.
		failure: protocol.#Failure @protobuf(4,type=Failure)
	}
}

// The CRDT state. This represents the full state of a CRDT. When received, a user function should replace the current
// state with this, not apply it as a delta. This includes both for the top level CRDT, and embedded CRDTs, such as
// the values of an ORMap.
#CrdtState: {
	{} | {
		// A Grow-only Counter
		gcounter: #GCounterState @protobuf(1)
	} | {
		// A Positve-Negative Counter
		pncounter: #PNCounterState @protobuf(2)
	} | {
		// A Grow-only Set
		gset: #GSetState @protobuf(3)
	} | {
		// An Observed-Removed Set
		orset: #ORSetState @protobuf(4)
	} | {
		// A Last-Write-Wins Register
		lwwregister: #LWWRegisterState @protobuf(5)
	} | {
		// A Flag
		flag: #FlagState @protobuf(6)
	} | {
		// An Observed-Removed Map
		ormap: #ORMapState @protobuf(7)
	} | {
		// A vote
		vote: #VoteState @protobuf(8)
	}
}

// A Grow-only counter
//
// A G-Counter can only be incremented, it can't be decremented.
#GCounterState: {
	// The current value of the counter.
	value?: uint64 @protobuf(1)
}

// A Positve-Negative Counter
//
// A PN-Counter can be both incremented and decremented.
#PNCounterState: {
	// The current value of the counter.
	value?: int64 @protobuf(1)
}

// A Grow-only Set
//
// A G-Set can only have items added, items cannot be removed.
#GSetState: {
	// The current items in the set.
	items?: [...{
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	}] @protobuf(1,type=google.protobuf.Any)
}

// An Observed-Removed Set
//
// An OR-Set may have items added and removed, with the condition that an item must be observed to be in the set before
// it is removed.
#ORSetState: {
	// The current items in the set.
	items?: [...{
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	}] @protobuf(1,type=google.protobuf.Any)
}

// A Last-Write-Wins Register
//
// A LWW-Register holds a single value, with the current value being selected based on when it was last written.
// The time of the last write may either be determined using the proxies clock, or may be based on a custom, domain
// specific value.
#LWWRegisterState: {
	// The current value of the register.
	value?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(1,type=google.protobuf.Any)

	// The clock to use if this state needs to be merged with another one.
	clock?: #CrdtClock @protobuf(2)

	// The clock value if the clock in use is a custom clock.
	customClockValue?: int64 @protobuf(3,name=custom_clock_value)
}

// A Flag
//
// A Flag is a boolean value, that once set to true, stays true.
#FlagState: {
	// The current value of the flag.
	value?: bool @protobuf(1)
}

// An Observed-Removed Map
//
// Like an OR-Set, an OR-Map may have items added and removed, with the condition that an item must be observed to be
// in the map before it is removed. The values of the map are CRDTs themselves. Different keys are allowed to use
// different CRDTs, and if an item is removed, and then replaced, the new value may be a different CRDT.
#ORMapState: {
	// The entries of the map.
	entries?: [...#ORMapEntry] @protobuf(1)
}

// An OR-Map entry.
#ORMapEntry: {
	// The entry key.
	key?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(1,type=google.protobuf.Any)

	// The value of the entry, a CRDT itself.
	value?: #CrdtState @protobuf(2)
}

// A Vote. This allows nodes to vote on something.
#VoteState: {
	// The number of votes for
	votesFor?: uint32 @protobuf(1,name=votes_for)

	// The total number of voters
	totalVoters?: uint32 @protobuf(2,name=total_voters)

	// The vote of the current node, which is included in the above two numbers
	selfVote?: bool @protobuf(3,name=self_vote)
}

// A CRDT delta
//
// Deltas only carry the change in value, not the full value (unless
#CrdtDelta: {
	{} | {
		gcounter: #GCounterDelta @protobuf(1)
	} | {
		pncounter: #PNCounterDelta @protobuf(2)
	} | {
		gset: #GSetDelta @protobuf(3)
	} | {
		orset: #ORSetDelta @protobuf(4)
	} | {
		lwwregister: #LWWRegisterDelta @protobuf(5)
	} | {
		flag: #FlagDelta @protobuf(6)
	} | {
		ormap: #ORMapDelta @protobuf(7)
	} | {
		vote: #VoteDelta @protobuf(8)
	}
}

#GCounterDelta: {
	increment?: uint64 @protobuf(1)
}

#PNCounterDelta: {
	change?: int64 @protobuf(1,type=sint64)
}

#GSetDelta: {
	added?: [...{
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	}] @protobuf(1,type=google.protobuf.Any)
}

#ORSetDelta: {
	// If cleared is set, the set must be cleared before added is processed.
	cleared?: bool @protobuf(1)
	removed?: [...{
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	}] @protobuf(2,type=google.protobuf.Any)
	added?: [...{
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	}] @protobuf(3,type=google.protobuf.Any)
}

#LWWRegisterDelta: {
	value?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(1,type=google.protobuf.Any)
	clock?:            #CrdtClock @protobuf(2)
	customClockValue?: int64      @protobuf(3,name=custom_clock_value)
}

#FlagDelta: {
	value?: bool @protobuf(1)
}

#ORMapDelta: {
	cleared?: bool @protobuf(1)
	removed?: [...{
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	}] @protobuf(2,type=google.protobuf.Any)
	updated?: [...#ORMapEntryDelta] @protobuf(3)
	added?: [...#ORMapEntry] @protobuf(4)
}

#ORMapEntryDelta: {
	// The entry key.
	key?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(1,type=google.protobuf.Any)
	delta?: #CrdtDelta @protobuf(2)
}

#VoteDelta: {
	// Only set by the user function to change the nodes current vote.
	selfVote?: bool @protobuf(1,name=self_vote)

	// Only set by the proxy to change the votes for and total voters.
	votesFor?:    int32 @protobuf(2,name=votes_for)
	totalVoters?: int32 @protobuf(3,name=total_voters)
}

#CrdtInit: {
	serviceName?: string     @protobuf(1,name=service_name)
	entityId?:    string     @protobuf(2,name=entity_id)
	state?:       #CrdtState @protobuf(3)
}

#CrdtDelete: {
}

#CrdtReply: {
	commandId?:    int64                  @protobuf(1,name=command_id)
	clientAction?: protocol.#ClientAction @protobuf(2,type=ClientAction,name=client_action)
	sideEffects?: [...protocol.#SideEffect] @protobuf(4,type=SideEffect,name=side_effects)
	stateAction?: #CrdtStateAction @protobuf(5,name=state_action)

	// If the request was streamed, setting this to true indicates that the command should
	// be handled as a stream. Subsequently, the user function may send CrdtStreamedMessage,
	// and a CrdtStreamCancelled message will be sent if the stream is cancelled (though
	// not if the a CrdtStreamedMessage ends the stream first).
	streamed?: bool @protobuf(6)
}

#CrdtStateAction: {
	{} | {
		create: #CrdtState @protobuf(5)
	} | {
		update: #CrdtDelta @protobuf(6)
	} | {
		delete: #CrdtDelete @protobuf(7)
	}
	writeConsistency?: #CrdtWriteConsistency @protobuf(8,name=write_consistency)
}

// May be sent as often as liked if the first reply set streamed to true
#CrdtStreamedMessage: {
	commandId?:    int64                  @protobuf(1,name=command_id)
	clientAction?: protocol.#ClientAction @protobuf(2,type=ClientAction,name=client_action)
	sideEffects?: [...protocol.#SideEffect] @protobuf(3,type=SideEffect,name=side_effects)

	// Indicates the stream should end, no messages may be sent for this command after this.
	endStream?: bool @protobuf(4,name=end_stream)
}

#CrdtStreamCancelledResponse: {
	commandId?: int64 @protobuf(1,name=command_id)
	sideEffects?: [...protocol.#SideEffect] @protobuf(2,type=SideEffect,name=side_effects)
	stateAction?: #CrdtStateAction @protobuf(3,name=state_action)
}
#CrdtWriteConsistency: "LOCAL" |
	"MAJORITY" |
	"ALL"

#CrdtWriteConsistency_value: {
	LOCAL:    0
	MAJORITY: 1
	ALL:      2
}
#CrdtClock:
	// Use the default clock for deciding the last write, which is the system clocks
	// milliseconds since epoch.
	"DEFAULT" |

	// Use the reverse semantics with the default clock, to enable first write wins.
	"REVERSE" |

	// Use a custom clock value, set using custom_clock_value.
	"CUSTOM" |

	// Use a custom clock value, but automatically increment it by one if the clock
	// value from the current value is equal to the custom_clock_value.
	"CUSTOM_AUTO_INCREMENT"

#CrdtClock_value: {
	DEFAULT:               0
	REVERSE:               1
	CUSTOM:                2
	CUSTOM_AUTO_INCREMENT: 3
}
