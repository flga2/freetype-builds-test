pwd = $(shell pwd)
build = $(pwd)/build/darwin_386
dist = $(pwd)/dist/darwin_386

version = 2.10.1
freetype = freetype-$(version)
zlib = zlib-1.2.11
libpng = libpng-1.6.37
harfbuzz = harfbuzz-2.5.3

clean-zlib:
	rm -rf $(build)/zlib
build-zlib: clean-zlib
	mkdir -p $(build)/zlib
	cd src/$(zlib) \
		&& CFLAGS=-m32 ./configure --prefix=$(build)/zlib --static \
		&& make \
		&& make install

clean-libpng:
	rm -rf $(build)/libpng
build-libpng: clean-libpng build-zlib
	mkdir -p $(build)/libpng
	cd src/$(libpng) \
		&& LDFLAGS="-L$(build)/zlib/lib -lz" CFLAGS="-m32" CPPFLAGS="-I $(build)/zlib/include -m32" ./configure \
			--prefix=$(build)/libpng \
			--enable-static \
			--with-zlib-prefix=$(build)/zlib \
		&& LD_LIBRARY_PATH=$(build)/zlib/lib CFLAGS="-m32" CPPFLAGS="-m32" make \
		&& make install

clean-freetype:
	rm -rf $(build)/freetype
build-freetype: clean-freetype build-libpng build-zlib
	mkdir -p $(build)/freetype
	cd src/$(freetype) \
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig CFLAGS="-m32" ./configure \
			--prefix=$(build)/freetype \
			--enable-static \
			--without-harfbuzz \
			--without-bzip2 \
		&& LD_LIBRARY_PATH=$(build)/zlib/lib:$(build)/libpng/lib make \
		&& make install

clean-harfbuzz:
	rm -rf $(build)/harfbuzz
build-harfbuzz: clean-harfbuzz build-libpng build-zlib build-freetype
	mkdir -p $(build)/harfbuzz
	cd src/$(harfbuzz) \
		&& autoreconf --force --install \
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig:$(build)/freetype/lib/pkgconfig CFLAGS="-m32" CXXFLAGS="-m32" ./configure \
			--prefix=$(build)/harfbuzz \
			--enable-static \
			--without-glib \
			--without-gobject \
			--without-cairo \
			--without-fontconfig \
			--without-icu \
			--without-graphite2 \
			--with-freetype \
			--without-uniscribe \
			--without-directwrite \
			--without-coretext \
		&& CFLAGS="-m32" CXXFLAGS="-m32" LD_LIBRARY_PATH=$(build)/zlib/lib:$(build)/libpng/lib:$(build)/freetype/lib make \
		&& make install

clean-freetypehb:
	rm -rf $(build)/freetypehb
build-freetypehb: clean-freetypehb build-libpng build-zlib build-harfbuzz
	mkdir -p $(build)/freetypehb
	cd src/$(freetype) \
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig:$(build)/harfbuzz/lib/pkgconfig CFLAGS="-m32" ./configure \
			--prefix=$(build)/freetypehb \
			--enable-static \
			--with-harfbuzz \
			--without-bzip2 \
		&& LD_LIBRARY_PATH=$(build)/zlib/lib:$(build)/libpng/lib:$(build)/harfbuzz/lib make \
		&& make install

build: build-freetype build-freetypehb

clean-dist:
	rm -rf $(dist)
dist: build clean-dist
	mkdir -p $(dist)/lib
	cp -r $(build)/freetype/include $(dist)
	libtool -static -o $(dist)/lib/libfreetype.a \
		$(build)/zlib/lib/libz.a \
		$(build)/libpng/lib/libpng16.a \
		$(build)/freetype/lib/libfreetype.a
	libtool -static -o $(dist)/lib/libfreetypehb.a \
		$(build)/zlib/lib/libz.a \
		$(build)/libpng/lib/libpng16.a \
		$(build)/harfbuzz/lib/libharfbuzz.a \
		$(build)/freetype/lib/libfreetype.a
	zip -r darwin_386.zip $(dist)

test-ft:
	CGO_ENABLED=1 GOOS=darwin GOARCH=386 go build -tags 'static' -o static main.go
	./static $(version)
test-ft-hb:
	CGO_ENABLED=1 GOOS=darwin GOARCH=386 go build -tags 'static harfbuzz' -o statichb main.go
	./statichb $(version)