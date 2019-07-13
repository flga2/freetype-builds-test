pwd = $(shell pwd)

all: build

clean-zlib-linux:
	rm -rf build/linux/zlib
build-zlib-linux: clean-zlib-linux
	mkdir -p build/linux/zlib
	echo $(pwd)
	cd src/zlib-1.2.11 \
	&& ./configure --prefix=$(pwd)/build/linux/zlib \
	&& make \
	&& make install

clean-libpng-linux:
	rm -rf build/linux/libpng
build-libpng-linux: clean-libpng-linux
	mkdir -p build/linux/libpng
	cd src/libpng-1.6.37 \
	&& LDFLAGS="-L$(pwd)/build/linux/zlib/lib" CPPFLAGS="-I $(pwd)/build/linux/zlib/include" ./configure \
		--prefix=$(pwd)/build/linux/libpng \
		--enable-static \
		--with-zlib-prefix=$(pwd)/build/linux/zlib \
	&& make \
	&& make install

build-linux: build-zlib-linux build-libpng-linux
	ls -la build/linux/zlib
	ls -la build/linux/libpng

build: build-linux