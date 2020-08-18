package main

import (
	"context"
	"fmt"
	"time"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/load"
	"github.com/jhump/protoreflect/desc/protoparse"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/reflect/protodesc"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/reflect/protoregistry"
	"google.golang.org/protobuf/types/dynamicpb"
)

func main() {
	//protos()
	runCue()
}

func protos() {
	filenames, err := protoparse.ResolveFilenames([]string{"./proto/"}, "protocol/cloudstate/entity.proto")
	if err != nil {
		panic(err)
	}
	fmt.Printf("filenames: %+v\n", filenames)
	p := protoparse.Parser{ImportPaths: []string{"./proto/"}}
	files, err := p.ParseFiles(filenames...)
	if err != nil {
		panic(err)
	}
	fmt.Printf("files: %+v\n", files)
	for _, f := range files {
		file, err := protodesc.NewFile(f.AsFileDescriptorProto(), protoregistry.GlobalFiles)
		if err != nil {
			panic(err)
		}
		fmt.Printf("file: %+v\n", file)
		service := file.Services().ByName("EntityDiscovery")
		fmt.Printf("service: %+v\n", service)
		discover := service.Methods().ByName("discover")
		fmt.Printf("discover: %+v\n", discover)
		input := dynamicpb.NewMessage(discover.Input())
		fmt.Printf("input: %+v\n", discover.Input())
		input.Set(discover.Input().Fields().ByJSONName("proxyName"), protoreflect.ValueOf("proxy-000"))
		fmt.Printf("input: %+v\n", input)

		conn, err := grpc.Dial("localhost:8080", grpc.WithInsecure())
		if err != nil {
			panic(err)
		}
		output := dynamicpb.NewMessage(discover.Output())
		ctx, cancelFunc := context.WithTimeout(context.Background(), 15*time.Second)
		defer cancelFunc()
		err = conn.Invoke(ctx, "cloudstate.EntityDiscovery/discover", input, output, grpc.EmptyCallOption{})
		if err != nil {
			panic(err)
		}
		fmt.Printf("output: %+v\n", output)
	}
}

func runCue() {
	var r cue.Runtime
	instances := load.Instances([]string{
		"./discover_seq.cue",
	},
		&load.Config{
			Dir: "./cue",
		},
	)
	for _, i := range instances {
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
