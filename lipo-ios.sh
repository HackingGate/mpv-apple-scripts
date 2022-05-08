#!/bin/sh -e

LIBRARIES="libuchardet libfribidi libfreetype libharfbuzz libass ffmpeg libmpv libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale"
OPENSSL="$(pwd)/openssl-ios"
ROOT="$(pwd)"
SCRATCH="$ROOT/scratch-ios"
LIB="$ROOT/lib-ios"
mkdir -p $LIB

for LIBRARY in $LIBRARIES; do
    if [[ "$LIBRARY" != "ffmpeg" ]]; then
        lipo -create $SCRATCH/arm64/lib/$LIBRARY.a $SCRATCH/x86_64/lib/$LIBRARY.a -o $LIB/$LIBRARY.a
    fi
done

cp $OPENSSL/lib/libcrypto.a $LIB/libcrypto.a
cp $OPENSSL/lib/libssl.a $LIB/libssl.a
