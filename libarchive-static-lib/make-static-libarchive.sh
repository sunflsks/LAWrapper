#!/bin/sh

# Fill these out with the path of their respective static libraries on your computer
#STATIC_ZSTD_PATH=""
#STATIC_LZ4_PATH=""
#STATIC_LIBB2_PATH=""

# Set if you want to download a specific libarchive version
#$LIBARCHIVE_VER="3.5.1"

#---------
# DO NOT MODIFY ANYTHING BELOW THIS LINE!
# --------

[ -z "$LIBARCHIVE_VER" ] && LIBARCHIVE_VER="3.5.1"

echo "This will create a static libarchive library."

[ -z "$STATIC_ZSTD_PATH" ] && { echo "STATIC_ZSTD_PATH unset!"; exit 10 ; }
[ -z "$STATIC_LZ4_PATH" ] && { echo "STATIC_LZ4_PATH unset!"; exit 9 ; }
[ -z "$STATIC_LIBB2_PATH" ] && { echo "STATIC_LIBB2_PATH unset!"; exit 8 ; }

if [ ! -d libarchive-"$LIBARCHIVE_VER" ]; then
	echo "Libarchive src not found, downloading version $LIBARCHIVE_VER..."	
	wget -O src.tar.gz "https://github.com/libarchive/libarchive/releases/download/$LIBARCHIVE_VER/libarchive-$LIBARCHIVE_VER.tar.gz" || { echo "Could not download sources! Exiting" ; exit 1 ; }
	tar -xf src.tar.gz
fi

cd "libarchive-$LIBARCHIVE_VER" || { echo "Couldn't change dir! Exiting..." ; exit 2 ; }

echo "Compiling sources now..."
cmake . -DZSTD_LIBRARY="$STATIC_ZSTD_PATH" -DZSTD_LIBRARY_RELEASE="$STATIC_ZSTD_PATH" \
		-DLZ4_LIBRARY=/"$STATIC_LZ4_PATH" -DLZ4_LIBRARY_RELEASE="$STATIC_LZ4_PATH" \
		-DLIBB2_LIBRARY="$STATIC_LIBB2_PATH" -DLIBB2_LIBRARY_RELEASE="$STATIC_LIBB2_PATH" \
		-G Ninja

ninja

mv libarchive/libarchive.a ..

echo "Done! output is in libarchive.a"
