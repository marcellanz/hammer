package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"time"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/load"
	"cuelang.org/go/encoding/gocode"
	"github.com/jhump/protoreflect/desc/protoparse"
	protocol "github.com/mrcllnz/hammer/proto/protocol/cloudstate"
	"google.golang.org/grpc"
	"google.golang.org/protobuf/encoding/protojson"
	"google.golang.org/protobuf/reflect/protodesc"
	"google.golang.org/protobuf/reflect/protoreflect"
	"google.golang.org/protobuf/reflect/protoregistry"
	"google.golang.org/protobuf/types/dynamicpb"
)

func main() {
	runCue()
	//protos()
	//genCue()
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

func genCue() {
	instances := load.Instances([]string{
		"./discover_seq.cue",
	},
		&load.Config{
			Dir: "./cue",
		},
	)
	var r cue.Runtime
	for _, i := range instances {
		instance, err := r.Build(i)
		if err != nil {
			panic(err)
		}
		b, err := gocode.Generate("main", instance, nil)
		if err != nil {
			// handle error
		}

		err = ioutil.WriteFile("cue_gen.go", b, 0644)
	}
}

func runCue() {
	var r cue.Runtime
	instances := load.Instances([]string{
		"./types.cue",
		"./discover_seq.cue",
	},
		&load.Config{
			Dir: "./cue",
		},
	)
	for _, i := range instances {
		fmt.Printf("pkg: %+v\n", i.PkgName)

		instance, err := r.Build(i)
		if err != nil {
			panic(err)
		}
		fmt.Printf("incomplete: %+v\n", instance.Incomplete)
		lookup := instance.Value().Lookup("all")
		fmt.Printf("exists: %+v\n", lookup.Exists())
		if !lookup.Exists() {
			continue
		}
		all := lookup.Eval()
		fmt.Printf("all.kind: %+v\n", all.Kind())
		fmt.Printf("all.len: %+v\n", all.Len())

		flows, err := all.List()
		if err != nil {
			panic(err)
		}
		for flows.Next() {
			flow := flows.Value()
			eval := flow.Eval()
			fmt.Printf("flows.flow: %+v\n", flow)
			fmt.Printf("flows.flow.value: %+v\n", eval)
			s, _ := flow.Struct()
			fmt.Printf("flows.flow.struct: %+v\n", s)
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
				s := sl.Value()
				reqF, err := s.FieldByName("req", false)
				if err != nil {
					panic(err)
				}
				req := reqF.Value.Eval()
				fmt.Printf("req: %+v\n", req)

				msg, err := req.FieldByName("msg", false)
				if err != nil {
					panic(err)
				}

				info := protocol.ProxyInfo{}
				json, err := msg.Value.MarshalJSON()
				if err != nil {
					panic(err)
				}
				err = protojson.Unmarshal(json, &info)
				if err != nil {
					panic(err)
				}
				fmt.Printf("msg: %+v\n", msg.Value.Eval())
				fmt.Printf("info: %+v\n", info)
			}
		}
	}
}
