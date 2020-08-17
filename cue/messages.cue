import "github.com/marcellanz/hammer/schemas/cloudstate:protocol"

proxyInfo: protocol.#ProxyInfo & {
	protocolMajorVersion: 1
	protocolMinorVersion: 0
	proxyName:            "TCK"
	proxyVersion:         "1.1.0"
	supportedEntityTypes: ["cloudstate.eventsourced.EventSourced"]
}