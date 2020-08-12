package persistence

#LineItem: {
	productId?: string @protobuf(1)
	name?:      string @protobuf(2)
	quantity?:  int32  @protobuf(3)
}

// The item added event.
#ItemAdded: {
	item?: #LineItem @protobuf(1)
}

// The item removed event.
#ItemRemoved: {
	productId?: string @protobuf(1)
}

// The shopping cart state.
#Cart: {
	items?: [...#LineItem] @protobuf(1)
}
