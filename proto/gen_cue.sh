#!/usr/bin/env bash

cue import -f -I /usr/local/Cellar/protobuf/3.12.4/include/ \
  -I ./protocol ./protocol/cloudstate/entity.proto

cue import -f -I /usr/local/Cellar/protobuf/3.12.4/include/ \
  -I ./protocol ./protocol/cloudstate/crdt.proto

cue import -f -I /usr/local/Cellar/protobuf/3.12.4/include/ \
  -I ./protocol ./protocol/cloudstate/event_sourced.proto

cue import -f -I /usr/local/Cellar/protobuf/3.12.4/include/ \
  -I ./protocol ./protocol/cloudstate/function.proto

cue import -f -I /usr/local/Cellar/protobuf/3.12.4/include/ \
  -I ./protocol ./frontend/cloudstate/entity_key.proto

cue import -f -I /usr/local/Cellar/protobuf/3.12.4/include/ \
  -I ./protocol ./frontend/google/api/http.proto

cue import -f -I /usr/local/Cellar/protobuf/3.12.4/include/ \
  -I ./protocol ./example/shoppingcart/persistence/domain.proto

cue import -f -I /usr/local/Cellar/protobuf/3.12.4/include/ \
  -I ./protocol -I ./frontend ./example/shoppingcart/shoppingcart.proto
