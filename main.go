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
	instances := load.Instances([]string{
		"./discover_seq.cue",
	},
		&load.Config{
			Dir: "./cue",
		},
	)
	for _, i := range instances {
		//fmt.Printf("complete: %+v\n", i.Complete())
		fmt.Printf("pkg: %+v\n", i.PkgName)

		build, err := r.Build(i)
		if err != nil {
			panic(err)
		}
		fmt.Printf("incomplete: %+v\n", build.Incomplete)
		lookup := build.Value().Lookup("all")
		fmt.Printf("exists: %+v\n", lookup.Exists())
		if !lookup.Exists() {
			continue
		}

		l := lookup.Eval()
		fmt.Printf("all.kind: %+v\n", l.Kind())
		fmt.Printf("all.len: %+v\n", l.Len())

		list, err := l.List()
		if err != nil {
			panic(err)
		}
		for list.Next() {
			value := list.Value()
			fmt.Printf("list.Value: %+v\n", value)
			eval := value.Eval()
			fmt.Printf("list.Value: %+v\n", eval)
			s, _ := value.Struct()
			fmt.Printf("list.Value: %+v\n", s)
			f, err := s.FieldByName("seq", false)
			if err != nil {
				panic(err)
			}
			seq := f.Value.Eval()
			fmt.Printf("seq: %+v\n", seq)

			sl, err := seq.List()
			if err != nil {
				panic(err)
			}
			for sl.Next() {
				se := sl.Value()
				req, err := se.FieldByName("req", false)
				if err != nil {
					panic(err)
				}
				fmt.Printf("req: %+v\n", req.Value.Eval())
			}
		}

		//if l.Kind() != cue.ListKind {
		//	panic("all is not a list")
		//}

		//_, err := v.List()
		//if err != nil {
		//	panic(err)
		//}
		//list.Next()
		//fi, err := v.FieldByName("msg001", false)
		//if err != nil {
		//	panic(err)
		//}
		//fmt.Printf("field: %+v\n", fi)
		//
		//m := &msg{}
		//err = fi.Value.Decode(m)
		//if err != nil {
		//	panic(err)
		//}
		//fmt.Printf("msg: %+v\n", m)
	}
}
