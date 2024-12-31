#!/bin/sh -e

LIBRARIES="libuchardet libfribidi libfreetype libharfbuzz libass ffmpeg libmpv libssl"
IOS_SDK_VERSION=$(xcrun -sdk iphoneos --show-sdk-version)
TVOS_SDK_VERSION=$(xcrun -sdk appletvos --show-sdk-version)

export PKG_CONFIG_PATH
export LDFLAGS
export CFLAGS
export CXXFLAGS
export COMMON_OPTIONS
export ENVIRONMENT
export ARCH
export PLATFORM
export CMAKE_OSX_ARCHITECTURES

while getopts "p:e:" OPTION; do
    case $OPTION in
    e)
        ENVIRONMENT=$(echo "$OPTARG" | awk '{print tolower($0)}')
        ;;
    p)
        PLATFORM=$(echo "$OPTARG" | awk '{print tolower($0)}')
        ;;
    ?)
        echo "Invalid option"
        exit 1
        ;;
    esac
done

export PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/:$PATH"

if [[ "$ENVIRONMENT" = "distribution" ]]; then
    ARCHS="arm64"
elif [[ "$ENVIRONMENT" = "development" ]]; then
    ARCHS="arm64"
elif [[ "$ENVIRONMENT" = "" ]]; then
    echo "An environment option is required (-e development or -e distribution)"
    exit 1
else
    echo "Unhandled environment option"
    exit 1
fi

if [[ "$PLATFORM" = "ios" ]]; then
    SDK_VERSION=$IOS_SDK_VERSION
    PLATFORM_SIMULATOR="iPhoneSimulator"
    PLATFORM_DEVICE="iPhoneOS"
    SDKPATH_SIMULATOR="$(xcodebuild -sdk iphonesimulator -version Path)"
    SDKPATH_DEVICE="$(xcodebuild -sdk iphoneos -version Path)"
elif [[ "$PLATFORM" = "tv" ]]; then
    SDK_VERSION=$TVOS_SDK_VERSION
    PLATFORM_SIMULATOR="AppleTVSimulator"
    PLATFORM_DEVICE="AppleTVOS"
    SDKPATH_SIMULATOR="$(xcodebuild -sdk appletvsimulator -version Path)"
    SDKPATH_DEVICE="$(xcodebuild -sdk appletvos -version Path)"
elif [[ "$PLATFORM" = "" ]]; then
    echo "A platform option is required (-p ios or -p tv)"
    exit 1
else
    echo "Unhandled platform option"
    exit 1
fi

ROOT="$(pwd)"
SCRIPTS="$ROOT/scripts"
SCRATCH="$ROOT/scratch-$PLATFORM"
export SRC="$ROOT/src"

for ARCH in $ARCHS; do
    echo "ARCH -- "$ARCH
    if [[ $ARCH = "arm64" ]]; then
        HOSTFLAG="aarch64"
        CMAKE_OSX_ARCHITECTURES=$ARCH
        if [[ "$ENVIRONMENT" = "development" ]]; then
            PLATFORM=$PLATFORM_SIMULATOR
            export SDKPATH=$SDKPATH_SIMULATOR
            ACFLAGS="-arch $ARCH -isysroot $SDKPATH"
            ALDFLAGS="-arch $ARCH -isysroot $SDKPATH -lbz2"
            OPENSSL="$ROOT/openssl/$PLATFORM$SDK_VERSION-arm64.sdk"
        else
            PLATFORM=$PLATFORM_DEVICE
            export SDKPATH=$SDKPATH_DEVICE
            ACFLAGS="-arch $ARCH -isysroot $SDKPATH"
            ALDFLAGS="-arch $ARCH -isysroot $SDKPATH -lbz2"
            OPENSSL="$ROOT/openssl/$PLATFORM$SDK_VERSION-arm64.sdk"
        fi
    elif [[ $ARCH = "x86_64" ]]; then
        HOSTFLAG="x86_64"
        CMAKE_OSX_ARCHITECTURES=$ARCH
        PLATFORM=$PLATFORM_SIMULATOR
        export SDKPATH=$SDKPATH_SIMULATOR
        ACFLAGS="-arch $ARCH -isysroot $SDKPATH"
        ALDFLAGS="-arch $ARCH -isysroot $SDKPATH -lbz2"
        OPENSSL="$ROOT/openssl/$PLATFORM$SDK_VERSION-$HOSTFLAG.sdk"
    else
        echo "Unhandled architecture option"
        exit 1
    fi

    CFLAGS="$ACFLAGS -Os"
    LDFLAGS="$ALDFLAGS -Os"
    CXXFLAGS="$CFLAGS"

    echo "OPENSSL PTAH -->$OPENSSL"
    CFLAGS="$CFLAGS -I$OPENSSL/include"
    LDFLAGS="$LDFLAGS -L$OPENSSL/lib"

    mkdir -p $SCRATCH

    PKG_CONFIG_PATH="$SCRATCH/$ARCH-$ENVIRONMENT/lib/pkgconfig"
    COMMON_OPTIONS="--prefix=$SCRATCH/$ARCH-$ENVIRONMENT --exec-prefix=$SCRATCH/$ARCH-$ENVIRONMENT --build=x86_64-apple-darwin14 --enable-static \
                    --disable-shared --disable-dependency-tracking --with-pic --host=$HOSTFLAG"

    for LIBRARY in $LIBRARIES; do
        case $LIBRARY in
        "libfribidi")
            echo "Building $LIBRARY, working directory: $SCRATCH/$ARCH-$ENVIRONMENT/fribidi, command: $SCRIPTS/fribidi-build"
            mkdir -p $SCRATCH/$ARCH-$ENVIRONMENT/fribidi && cd $_ && $SCRIPTS/fribidi-build
            ;;
        "libfreetype")
            echo "Building $LIBRARY, working directory: $SCRATCH/$ARCH-$ENVIRONMENT/freetype, command: $SCRIPTS/freetype-build"
            mkdir -p $SCRATCH/$ARCH-$ENVIRONMENT/freetype && cd $_ && $SCRIPTS/freetype-build
            ;;
        "libharfbuzz")
            echo "Building $LIBRARY, working directory: $SCRATCH/$ARCH-$ENVIRONMENT/harfbuzz, command: $SCRIPTS/harfbuzz-build"
            mkdir -p $SCRATCH/$ARCH-$ENVIRONMENT/harfbuzz && cd $_ && $SCRIPTS/harfbuzz-build
            ;;
        "libass")
            echo "Building $LIBRARY, working directory: $SCRATCH/$ARCH-$ENVIRONMENT/libass, command: $SCRIPTS/libass-build"
            mkdir -p $SCRATCH/$ARCH-$ENVIRONMENT/libass && cd $_ && $SCRIPTS/libass-build
            ;;
        "libuchardet")
            echo "Building $LIBRARY, working directory: $SCRATCH/$ARCH-$ENVIRONMENT/uchardet, command: $SCRIPTS/uchardet-build"
            mkdir -p $SCRATCH/$ARCH-$ENVIRONMENT/uchardet && cd $_ && $SCRIPTS/uchardet-build
            ;;
        "ffmpeg")
            echo "Building $LIBRARY, working directory: $SCRATCH/$ARCH-$ENVIRONMENT/ffmpeg, command: $SCRIPTS/ffmpeg-build"
            mkdir -p $SCRATCH/$ARCH-$ENVIRONMENT/ffmpeg && cd $_ && $SCRIPTS/ffmpeg-build
            ;;
        "libmpv")
            if [[ "$ENVIRONMENT" = "development" ]]; then
                CFLAGS="$ACFLAGS -g2 -Og"
                LDFLAGS="$ALDFLAGS -g2 -Og"
            fi
            echo "Building $LIBRARY, working directory: ${PWD}, command: $SCRIPTS/mpv-build && cp $SRC/mpv*/build/libmpv.a $SCRATCH/$ARCH-$ENVIRONMENT/lib"
            $SCRIPTS/mpv-build && cp $SRC/mpv*/build/libmpv.a "$SCRATCH/$ARCH-$ENVIRONMENT/lib"
            ;;
        "libssl")
            echo "Building $LIBRARY, working directory: ${PWD}, "
            echo "command: cp -a $OPENSSL/include/. $SCRATCH/$ARCH-$ENVIRONMENT/include/"
            echo "command:  cp -a $OPENSSL/lib/. $SCRATCH/$ARCH-$ENVIRONMENT/lib/"
            cp -a $OPENSSL/include/. $SCRATCH/$ARCH-$ENVIRONMENT/include/
            cp -a $OPENSSL/lib/. $SCRATCH/$ARCH-$ENVIRONMENT/lib/
            ;;
        esac
    done
done
