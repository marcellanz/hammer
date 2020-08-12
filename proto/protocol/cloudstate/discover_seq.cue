msg001: #ProxyInfo & {
	protocolMajorVersion: 1  @protobuf(1,name=protocol_major_version)
	protocolMinorVersion: 0  @protobuf(2,name=protocol_minor_version)
	proxyName:            "TCK" @protobuf(3,name=proxy_name)
	proxyVersion:         "1.1.0" @protobuf(4,name=proxy_version)
	supportedEntityTypes: ["cloudstate.eventsourced.EventSourced"] @protobuf(5,name=supported_entity_types)
}