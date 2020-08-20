// _+build ignore

package main

import (
	"io/ioutil"
	"log"
	"os"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/load"
	"cuelang.org/go/encoding/gocode"
)

func main() {
	cwd, err := os.Getwd()
	if err != nil {
		log.Fatal(err)
	}

	inst := cue.Build(load.Instances([]string{
		"types.cue",
		//"discover_seq.cue",
	}, &load.Config{
		Dir:        cwd,
		ModuleRoot: cwd,
		Module:     "github.com/marcellanz/hammer",
	}))[0]
	if inst.Err != nil {
		log.Fatal(inst.Err)
	}

	b, err := gocode.Generate(".", inst, &gocode.Config{})
	if err != nil {
		log.Fatal(err)
	}

	if err := ioutil.WriteFile("types.go", b, 0644); err != nil {
		log.Fatal(err)
	}
}
