package shoppingcart

#AddLineItem: {
	userId?:    string @protobuf(1,name=user_id,"(.cloudstate.entity_key)")
	productId?: string @protobuf(2,name=product_id)
	name?:      string @protobuf(3)
	quantity?:  int32  @protobuf(4)
}

#RemoveLineItem: {
	userId?:    string @protobuf(1,name=user_id,"(.cloudstate.entity_key)")
	productId?: string @protobuf(2,name=product_id)
}

#GetShoppingCart: {
	userId?: string @protobuf(1,name=user_id,"(.cloudstate.entity_key)")
}

#LineItem: {
	productId?: string @protobuf(1,name=product_id)
	name?:      string @protobuf(2)
	quantity?:  int32  @protobuf(3)
}

#Cart: {
	items?: [...#LineItem] @protobuf(1)
}
