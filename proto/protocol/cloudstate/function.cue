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

#FunctionCommand: {
	// The name of the service this function is on.
	serviceName?: string @protobuf(2,name=service_name)

	// Command name
	name?: string @protobuf(3)

	// The command payload.
	payload?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(4,type=google.protobuf.Any)
}

#FunctionReply: {
	{} | {
		reply: protocol.#Reply @protobuf(2,type=Reply)
	} | {
		forward: protocol.#Forward @protobuf(3,type=Forward)
	}
	sideEffects?: [...protocol.#SideEffect] @protobuf(4,type=SideEffect,name=side_effects)
}
