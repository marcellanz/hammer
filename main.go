package main

import (
	"context"
	"fmt"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/load"
	"github.com/jhump/protoreflect/desc/protoparse"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/reflect/protodesc"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/reflect/protoregistry"
	"google.golang.org/protobuf/types/dynamicpb"
)

/*
The google.golang.org/protobuf  module provides no means of parsing .proto  files. @jhump has written a fairly
faithful Go implementation at https://pkg.go.dev/github.com/jhump/protoreflect/desc/protoparse. Using that package,
you can parse a set of .proto  files into a set of descriptorpb.FileDescriptorProto messages. Next, you can convert
the FileDescriptorProto messages into protoreflect descriptors using the google.golang.org/protobuf/reflect/protodesc
package. Lastly, with a protoreflect.MessageDescriptor  on hand, you can create a message at runtime from it using
google.golang.org/protobuf/types/dynamicpb .

pkg.go.devpkg.go.dev
protoparse package · pkg.go.dev
Go is an open source programming language that makes it easy to build simple, reliable, and efficient software.

There's uncertain overlap in responsibility between the google.golang.org/protobuf project and the main
github.com/protocolbuffers/protobuf project for providing a .proto  parsers. They already have a .proto
parser in the form of protoc . At the present moment, it's not on our radar to implement a .proto  parser.
Based on the bugs that @jhump has filed against the main protobuf project, it seems that he has gone to some
lengths to make sure his implementation matches protoc  behavior to a large degree. I think it's fine if the
community uses his implementation rather than trying to use libprotoc  through cgo or shelling out to protoc.

*/

type msg struct {
	ProtocolMajorVersion int32
	ProtocolMinorVersion int32
	ProxyName            string
	ProxyVersion         string
	SupportedEntityTypes []string
}

func protos() {
	//in, err := ioutil.ReadFile("./proto/protocol/cloudstate/entity.proto")
	//if err != nil {
	//	panic(err)
	//}
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

		dial, err := grpc.Dial("localhost:8080", grpc.WithInsecure())
		if err != nil {
			panic(err)
		}
		output := dynamicpb.NewMessage(discover.Output())
		err = dial.Invoke(context.Background(), "cloudstate.EntityDiscovery/discover", input, output, grpc.EmptyCallOption{})
		if err != nil {
			panic(err)
		}
		fmt.Printf("output: %+v\n", output)
	}
}

func main() {
	protos()
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
