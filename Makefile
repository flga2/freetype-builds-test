pwd = $(shell pwd)
build_dir_linux = $(pwd)/build/linux
dist_dir_linux = $(pwd)/dist/linux

zlib = zlib-1.2.11
libpng = libpng-1.6.37
freetype = freetype-2.10.1
harfbuzz = harfbuzz-2.5.3

define freetype-ar-script
create libfreetype.a
addlib $(build_dir_linux)/zlib/lib/libz.a
addlib $(build_dir_linux)/libpng/lib/libpng16.a
addlib $(build_dir_linux)/freetype/lib/libfreetype.a
save
endef
define freetypehb-ar-script
create libfreetype.a
addlib $(build_dir_linux)/zlib/lib/libz.a
addlib $(build_dir_linux)/libpng/lib/libpng16.a
addlib $(build_dir_linux)/harfbuzz/lib/libharfbuzz.a\n\
addlib $(build_dir_linux)/freetype/lib/libfreetype.a
save
endef

clean-zlib-linux:
	rm -rf $(build_dir_linux)/zlib
build-zlib-linux: clean-zlib-linux
	mkdir -p $(build_dir_linux)/zlib
	echo $(pwd)
	cd src/$(zlib) \
	&& ./configure --prefix=$(build_dir_linux)/zlib \
	&& make \
	&& make install
	cd src/$(zlib) \
	&& ./configure \
	&& make \
	&& make install

clean-libpng-linux:
	rm -rf $(build_dir_linux)/libpng
build-libpng-linux: clean-libpng-linux
	mkdir -p $(build_dir_linux)/libpng
	cd src/$(libpng) \
	&& LD_LIBRARY_PATH=$(build_dir_linux)/zlib/lib \
		LDFLAGS="-L$(build_dir_linux)/zlib/lib" \
		CPPFLAGS="-I $(build_dir_linux)/zlib/include" ./configure \
		--prefix=$(build_dir_linux)/libpng \
		--enable-static \
		--with-zlib-prefix=$(build_dir_linux)/zlib \
	&& make \
	&& make install

clean-freetype-linux:
	rm -rf $(build_dir_linux)/freetype
build-freetype-linux: clean-freetype-linux
	mkdir -p $(build_dir_linux)/freetype
	cd src/$(freetype) \
	&& LD_LIBRARY_PATH=$(build_dir_linux)/zlib/lib:$(build_dir_linux)/libpng/lib \
		PKG_CONFIG_LIBDIR=$(build_dir_linux)/zlib/lib/pkgconfig:$(build_dir_linux)/libpng/lib/pkgconfig ./configure \
		--prefix=$(build_dir_linux)/freetype \
		--enable-static \
		--without-harfbuzz \
		--without-bzip2 \
	&& make \
	&& make install

clean-harfbuzz-linux:
	rm -rf $(build_dir_linux)/harfbuzz
build-harfbuzz-linux: clean-harfbuzz-linux
	mkdir -p $(build_dir_linux)/harfbuzz
	cd src/$(harfbuzz) \
	&& autoreconf --force --install \
	&& LD_LIBRARY_PATH=$(build_dir_linux)/zlib/lib:$(build_dir_linux)/libpng/lib:$(build_dir_linux)/freetype/lib \
		PKG_CONFIG_LIBDIR=$(build_dir_linux)/zlib/lib/pkgconfig:$(build_dir_linux)/libpng/lib/pkgconfig:$(build_dir_linux)/freetype/lib/pkgconfig ./configure \
		--prefix=$(build_dir_linux)/harfbuzz \
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
	&& make \
	&& make install

clean-freetypehb-linux:
	rm -rf $(build_dir_linux)/freetypehb
build-freetypehb-linux: clean-freetypehb-linux
	mkdir -p $(build_dir_linux)/freetypehb
	cd src/$(freetype) \
	&& LD_LIBRARY_PATH=$(build_dir_linux)/zlib/lib:$(build_dir_linux)/libpng/lib:$(build_dir_linux)/harfbuzz/lib \
		PKG_CONFIG_LIBDIR=$(build_dir_linux)/zlib/lib/pkgconfig:$(build_dir_linux)/libpng/lib/pkgconfig:$(build_dir_linux)/harfbuzz/lib/pkgconfig ./configure \
		--prefix=$(build_dir_linux)/freetypehb \
		--enable-static \
		--with-harfbuzz \
		--without-bzip2 \
	&& make \
	&& make install

build-linux: build-zlib-linux build-libpng-linux build-freetype-linux build-harfbuzz-linux build-freetypehb-linux

clean-dist-linux:
	rm -rf $(dist_dir_linux)
dist-linux: build-linux clean-dist-linux
	mkdir -p $(dist_dir_linux)/lib
	cp -r $(build_dir_linux)/freetype/include $(dist_dir_linux)
	cd $(dist_dir_linux)/lib && echo $(freetype-ar-script) | ar -M 
	cd $(dist_dir_linux)/lib && echo $(freetypehb-ar-script) | ar -M 
	ls -la $(dist_dir_linux)
	ls -la $(dist_dir_linux)/include
	ls -la $(dist_dir_linux)/lib