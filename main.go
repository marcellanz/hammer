package main

import (
	"fmt"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/load"
)

type msg struct {
	ProtocolMajorVersion int32
	ProtocolMinorVersion int32
	ProxyName            string
	ProxyVersion         string
	SupportedEntityTypes []string
}

func main() {
	var r cue.Runtime
	//instance, err := r.Compile("./proto/protocol/cloudstate/discover_seq.cue", nil)
	//if err != nil {
	//	panic(err)
	//}
	//instance.Value()

	instances := load.Instances([]string{
		"./proto/protocol/cloudstate/entity.cue",
		"./proto/protocol/cloudstate/discover_seq.cue"},
		nil,
	)
	for _, i := range instances {
		fmt.Printf("%+v\n", i.Complete())
		fmt.Printf("%+v\n", i.PkgName)

		build, err := r.Build(i)
		if err != nil {
			panic(err)
		}
		lookup := build.Value().Lookup("msg001")
		fmt.Printf("exists: %+v\n", lookup.Exists())
		fmt.Printf("incomplete: %+v\n", build.Incomplete)
		v := build.Value()
		fi, err := v.FieldByName("msg001", false)
		if err != nil {
			panic(err)
		}
		fmt.Printf("field: %+v\n", fi)

		m := &msg{}
		err = fi.Value.Decode(m)
		if err != nil {
			panic(err)
		}
		fmt.Printf("msg: %+v\n", m)
	}
}
