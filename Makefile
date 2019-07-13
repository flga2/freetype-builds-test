all: build

clean-zlib-linux:
	rm -rf build/linux/zlib
build-zlib-linux: clean-zlib-linux
	mkdir -p build/linux/zlib
	cd src/zlib-1.2.11 \
	&& ./configure --prefix=build/linux/zlib \
	&& make \
	&& make install

clean-libpng-linux:
	rm -rf build/linux/libpng
build-libpng-linux: clean-libpng-linux
	mkdir -p build/linux/libpng
	cd src/libpng-1.6.37 \
	&& LDFLAGS="-L/freetype2/build/zlib/lib" CPPFLAGS="-I /freetype2/build/zlib/include" ./configure \
		--prefix=build/linux/libpng \
		--enable-static \
		--with-zlib-prefix=build/linux/zlib \
	&& make \
	&& make install

build-linux: build-zlib-linux build-libpng-linux
	ls -la build/linux/zlib
	ls -la build/linux/libpng

build: build-linux