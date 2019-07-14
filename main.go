package main

// #cgo CFLAGS: -I${SRCDIR}/dist/include -I${SRCDIR}/dist/include/freetype2 -Werror -Wall -Wextra -Wno-unused-parameter
// #cgo LDFLAGS: -L${SRCDIR}/dist/lib -lfreetype_amd64 -lm
// #include <ft2build.h>
// #include FT_FREETYPE_H
import "C"
import (
	"errors"
	"fmt"
	"os"
	"strconv"
	"strings"
)

func main() {
	args := os.Args[1:]
	if len(args) < 1 {
		fmt.Fprintln(os.Stderr, "version is required")
		os.Exit(1)
		return
	}

	emajor, eminor, epatch, err := parse(args[0])
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
		return
	}

	var ft C.FT_Library
	if err := C.FT_Init_FreeType(&ft); err != 0 {
		fmt.Fprintln(os.Stderr, "unable to init freetype")
		os.Exit(int(err))
		return
	}
	defer C.FT_Done_FreeType(ft)

	var amajor, aminor, apatch C.FT_Int
	C.FT_Library_Version(ft, &amajor, &aminor, &apatch)

	if int(amajor) != emajor || int(aminor) != eminor || int(apatch) != epatch {
		fmt.Fprintf(os.Stderr, "unexpected version, want %d.%d.%d, got %d.%d.%d\n", emajor, eminor, epatch, int(amajor), int(aminor), int(apatch))
		os.Exit(2)
		return
	}

	fmt.Println("FreeType OK")
}

func parse(s string) (int, int, int, error) {
	errv := errors.New("version should be in %d.%d.%d format")
	parts := strings.Split(s, ".")
	if len(parts) != 3 {
		return 0, 0, 0, errv
	}

	var major, minor, patch int
	var err error
	if major, err = strconv.Atoi(parts[0]); err != nil {
		return 0, 0, 0, errv
	}
	if minor, err = strconv.Atoi(parts[1]); err != nil {
		return 0, 0, 0, errv
	}
	if patch, err = strconv.Atoi(parts[2]); err != nil {
		return 0, 0, 0, errv
	}

	return major, minor, patch, nil
}
