package main

// #cgo CFLAGS: -I${SRCDIR}/dist/include -I${SRCDIR}/dist/include/freetype2 -Werror -Wall -Wextra -Wno-unused-parameter
// #cgo LDFLAGS: -L${SRCDIR}/dist/lib -lfreetype -lm
import "C"
import (
	"fmt"
	"os"
)

func main() {
	var ft C.FT_Library
	if err := C.FT_Init_FreeType(&ft); err != 0 {
		os.Exit(err)
	}
	var amajor, aminor, apatch C.FT_Int
	C.FT_Library_Version(l.ptr, &amajor, &aminor, &apatch)
	fmt.Printf("%d.%d.%d", amajor, aminor, apatch)
}
