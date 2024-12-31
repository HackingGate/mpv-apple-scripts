#!/bin/sh -e

LIBRARIES="libuchardet libfribidi libfreetype libharfbuzz libass libmpv libavcodec libavdevice libavfilter libavformat libavutil libswresample libswscale libcrypto libssl"
PLATFORMS="ios tv"
ROOT="$(pwd)"
LIB="$ROOT/lib"

rm -rf $LIB

mkdir -p $LIB

for LIBRARY in $LIBRARIES; do

    FRAMEWORKS=""

    for PLATFORM in $PLATFORMS; do
        SCRATCH="$ROOT/scratch-$PLATFORM"

        if [ -d "$SCRATCH/arm64-development" ]; then
            ENVIRONMENTS="$ENVIRONMENTS development"
            mkdir -p $SCRATCH/development/$LIBRARY.framework
            lipo -create $SCRATCH/arm64-development/lib/$LIBRARY.a -o $SCRATCH/development/$LIBRARY.framework/$LIBRARY
        fi

        if [[ -d "$SCRATCH/arm64-distribution" ]]; then
            ENVIRONMENTS="$ENVIRONMENTS distribution"
            mkdir -p $SCRATCH/distribution/$LIBRARY.framework
            cp $SCRATCH/arm64-distribution/lib/$LIBRARY.a $SCRATCH/distribution/$LIBRARY.framework/$LIBRARY
        fi

        for ENVIRONMENT in $ENVIRONMENTS; do
            cp -a $ROOT/framework-meta/Info.plist $SCRATCH/$ENVIRONMENT/$LIBRARY.framework/Info.plist
            sed -i "" "s/{NAME}/$LIBRARY/g" $SCRATCH/$ENVIRONMENT/$LIBRARY.framework/Info.plist
            if [[ "$LIBRARY" = "libmpv" ]]; then
                cp -a $ROOT/framework-meta/libmpv/. $SCRATCH/$ENVIRONMENT/$LIBRARY.framework/
            fi

            FRAMEWORKS="$FRAMEWORKS -framework $SCRATCH/$ENVIRONMENT/$LIBRARY.framework"

        done
    done

    xcodebuild -create-xcframework $FRAMEWORKS -output $LIB/$LIBRARY.xcframework

    FULL_INFO_PLIST_PATH=$LIB"/"$LIBRARY".xcframework/Info.plist"
    /usr/libexec/PlistBuddy -c "Add :MinimumOSVersion string 15.1" "$FULL_INFO_PLIST_PATH"
done
