package hammer

//import "github.com/marcellanz/hammer/schemas/cloudstate:protocol"

//Huh: {
//    Target: string @go(TTarget)
//} @go(Huh,validate=Val,complete=Hihi)
//
//#Huh2: {
//    target: string @go(Target)
//} @go(Huh2,complete=Hihi)

#Conn: {
	target: string
}

#Flow: {
	name:    string
	conn:    #Conn
	service: #Service
	seq: [...#Seq]
} @go(Flow,{func})

#Service: {
	name:   string
	method: string
	proto:  string
}

#Seq: {
	req: {
		msg:     _ //protocol.#ProxyInfo
		meta?:   #Meta
		stream?: #Stream
	}
	resp?: {
//		msg?:    protocol.#EntitySpec | #GRPCError
		msg?:    _ | #GRPCError
		meta?:   #Meta
		stream?: #Stream
	}
	stream?: #Stream
}

#Stream: {
	closed:         bool | *false
	gRCPErrorCode?: string | uint
}

#GRPCError: {
}

#Meta: {
	timeout: uint | *60
	headers?: [string]: string
	...
}
