package main

import (
	"fmt"

	"github.com/gam2046/vscode-contaniner-golang-template/src/info"
)

func main() {
	fmt.Println("Hello World.")
	fmt.Println(info.GetBuildInfo())
}
