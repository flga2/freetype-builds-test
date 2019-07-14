pwd = $(shell pwd)
build = $(pwd)/build
dist = $(pwd)/dist

version = 2.10.1
freetype = freetype-$(version)
zlib = zlib-1.2.11
libpng = libpng-1.6.37
harfbuzz = harfbuzz-2.5.3

define freetype_ar_script
create libfreetype.a
addlib $(build)/zlib/lib/libz.a
addlib $(build)/libpng/lib/libpng16.a
addlib $(build)/freetype/lib/libfreetype.a
save
endef
define freetypehb_ar_script
create libfreetypehb.a
addlib $(build)/zlib/lib/libz.a
addlib $(build)/libpng/lib/libpng16.a
addlib $(build)/harfbuzz/lib/libharfbuzz.a\n\
addlib $(build)/freetype/lib/libfreetype.a
save
endef
export freetype_ar_script
export freetypehb_ar_script

clean-zlib:
	rm -rf $(build)/zlib
build-zlib: clean-zlib
	mkdir -p $(build)/zlib
	cd src/$(zlib) \
		&& ./configure --prefix=$(build)/zlib \
		&& make \
		&& make install

clean-libpng:
	rm -rf $(build)/libpng
build-libpng: clean-libpng build-zlib
	mkdir -p $(build)/libpng
	cd src/$(libpng) \
		&& LDFLAGS="-L$(build)/zlib/lib" CPPFLAGS="-I $(build)/zlib/include" ./configure \
			--prefix=$(build)/libpng \
			--enable-static \
			--with-zlib-prefix=$(build)/zlib \
		&& LD_LIBRARY_PATH=$(build)/zlib/lib make \
		&& make install

clean-freetype:
	rm -rf $(build)/freetype
build-freetype: clean-freetype build-libpng build-zlib
	mkdir -p $(build)/freetype
	cd src/$(freetype) \
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig ./configure \
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
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig:$(build)/freetype/lib/pkgconfig ./configure \
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
		&& LD_LIBRARY_PATH=$(build)/zlib/lib:$(build)/libpng/lib:$(build)/freetype/lib make \
		&& make install

clean-freetypehb:
	rm -rf $(build)/freetypehb
build-freetypehb: clean-freetypehb build-libpng build-zlib build-harfbuzz
	mkdir -p $(build)/freetypehb
	cd src/$(freetype) \
		&& PKG_CONFIG_LIBDIR=$(build)/zlib/lib/pkgconfig:$(build)/libpng/lib/pkgconfig:$(build)/harfbuzz/lib/pkgconfig ./configure \
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
	cd $(dist)/lib && echo "$$freetype_ar_script" | ar -M
	cd $(dist)/lib && echo "$$freetypehb_ar_script" | ar -M 

test: dist
	go run main.go $(version)