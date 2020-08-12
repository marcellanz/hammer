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

// The init message. This will always be the first message sent to the entity when
// it is loaded.
#EventSourcedInit: {
	serviceName?: string @protobuf(1,name=service_name)

	// The ID of the entity.
	entityId?: string @protobuf(2,name=entity_id)

	// If present the entity should initialise its state using this snapshot.
	snapshot?: #EventSourcedSnapshot @protobuf(3)
}

// A snapshot
#EventSourcedSnapshot: {
	// The sequence number when the snapshot was taken.
	snapshotSequence?: int64 @protobuf(1,name=snapshot_sequence)

	// The snapshot.
	snapshot?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(2,type=google.protobuf.Any)
}

// An event. These will be sent to the entity when the entity starts up.
#EventSourcedEvent: {
	// The sequence number of the event.
	sequence?: int64 @protobuf(1)

	// The event payload.
	payload?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(2,type=google.protobuf.Any)
}

// A reply to a command.
#EventSourcedReply: {
	// The id of the command being replied to. Must match the input command.
	commandId?: int64 @protobuf(1,name=command_id)

	// The action to take
	clientAction?: protocol.#ClientAction @protobuf(2,type=ClientAction,name=client_action)

	// Any side effects to perform
	sideEffects?: [...protocol.#SideEffect] @protobuf(3,type=SideEffect,name=side_effects)

	// A list of events to persist - these will be persisted before the reply
	// is sent.
	events?: [...{
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	}] @protobuf(4,type=google.protobuf.Any)

	// An optional snapshot to persist. It is assumed that this snapshot will have
	// the state of any events in the events field applied to it. It is illegal to
	// send a snapshot without sending any events.
	snapshot?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(5,type=google.protobuf.Any)
}

// Input message type for the gRPC stream in.
#EventSourcedStreamIn: {
	{} | {
		init: #EventSourcedInit @protobuf(1)
	} | {
		event: #EventSourcedEvent @protobuf(2)
	} | {
		command: protocol.#Command @protobuf(3,type=Command)
	}
}

// Output message type for the gRPC stream out.
#EventSourcedStreamOut: {
	{} | {
		reply: #EventSourcedReply @protobuf(1)
	} | {
		failure: protocol.#Failure @protobuf(2,type=Failure)
	}
}
