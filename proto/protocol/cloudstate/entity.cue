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

// A reply to the sender.
#Reply: {
	// The reply payload
	payload?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(1,type=google.protobuf.Any)
}

// Forwards handling of this request to another entity.
#Forward: {
	// The name of the service to forward to.
	serviceName?: string @protobuf(1,name=service_name)

	// The name of the command.
	commandName?: string @protobuf(2,name=command_name)

	// The payload.
	payload?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(3,type=google.protobuf.Any)
}

// An action for the client
#ClientAction: {
	{} | {
		// Send a reply
		reply: #Reply @protobuf(1)
	} | {
		// Forward to another entity
		forward: #Forward @protobuf(2)
	} | {
		// Send a failure to the client
		failure: #Failure @protobuf(3)
	}
}

// A side effect to be done after this command is handled.
#SideEffect: {
	// The name of the service to perform the side effect on.
	serviceName?: string @protobuf(1,name=service_name)

	// The name of the command.
	commandName?: string @protobuf(2,name=command_name)

	// The payload of the command.
	payload?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(3,type=google.protobuf.Any)

	// Whether this side effect should be performed synchronously, ie, before the reply is eventually
	// sent, or not.
	synchronous?: bool @protobuf(4)
}

// A command. For each command received, a reply must be sent with a matching command id.
#Command: {
	// The ID of the entity.
	entityId?: string @protobuf(1,name=entity_id)

	// A command id.
	id?: int64 @protobuf(2)

	// Command name
	name?: string @protobuf(3)

	// The command payload.
	payload?: {
		// A URL/resource name that uniquely identifies the type of the serialized protocol buffer message. This string must contain at least one "/" character. The last segment of the URL's path must represent the fully qualified name of the type (as in `type.googleapis.com/google.protobuf.Duration`). The name should be in a canonical form (e.g., leading "." is not accepted).
		// The remaining fields of this object correspond to fields of the proto messsage. If the embedded message is well-known and has a custom JSON representation, that representation is assigned to the 'value' field.
		"@type": string
	} @protobuf(4,type=google.protobuf.Any)

	// Whether the command is streamed or not
	streamed?: bool @protobuf(5)
}

#StreamCancelled: {
	// The ID of the entity
	entityId?: string @protobuf(1,name=entity_id)

	// The command id
	id?: int64 @protobuf(2)
}

// A failure reply. If this is returned, it will be translated into a gRPC unknown
// error with the corresponding description if supplied.
#Failure: {
	// The id of the command being replied to. Must match the input command.
	commandId?: int64 @protobuf(1,name=command_id)

	// A description of the error.
	description?: string @protobuf(2)
}

#EntitySpec: {
	// This should be the Descriptors.FileDescriptorSet in proto serialized from as generated by:
	// protoc --include_imports \
	// --proto_path=<proto file directory> \
	// --descriptor_set_out=user-function.desc \
	// <path to .proto files>
	proto?: bytes @protobuf(1)

	// The entities being served.
	entities?: [...#Entity] @protobuf(2)

	// Optional information about the service.
	serviceInfo?: #ServiceInfo @protobuf(3,name=service_info)
}

// Information about the service that proxy is proxying to.
// All of the information in here is optional. It may be useful for debug purposes.
#ServiceInfo: {
	// The name of the service, eg, "shopping-cart".
	serviceName?: string @protobuf(1,name=service_name)

	// The version of the service.
	serviceVersion?: string @protobuf(2,name=service_version)

	// A description of the runtime for the service. Can be anything, but examples might be:
	// - node v10.15.2
	// - OpenJDK Runtime Environment 1.8.0_192-b12
	serviceRuntime?: string @protobuf(3,name=service_runtime)

	// If using a support library, the name of that library, eg "cloudstate"
	supportLibraryName?: string @protobuf(4,name=support_library_name)

	// The version of the support library being used.
	supportLibraryVersion?: string @protobuf(5,name=support_library_version)
}

#Entity: {
	// The type of entity. By convention, this should be a fully qualified entity protocol grpc
	// service name, for example, cloudstate.eventsourced.EventSourced.
	entityType?: string @protobuf(1,name=entity_type)

	// The name of the service to load from the protobuf file.
	serviceName?: string @protobuf(2,name=service_name)

	// The ID to namespace state by. How this is used depends on the type of entity, for example,
	// event sourced entities will prefix this to the persistence id.
	persistenceId?: string @protobuf(3,name=persistence_id)
}

#UserFunctionError: {
	message?: string @protobuf(1)
}

#ProxyInfo: {
	protocolMajorVersion?: int32  @protobuf(1,name=protocol_major_version)
	protocolMinorVersion?: int32  @protobuf(2,name=protocol_minor_version)
	proxyName?:            string @protobuf(3,name=proxy_name)
	proxyVersion?:         string @protobuf(4,name=proxy_version)
	supportedEntityTypes?: [...string] @protobuf(5,name=supported_entity_types)
}
