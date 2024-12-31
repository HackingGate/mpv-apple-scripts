#!/bin/sh -e

OPENSSL_VERSION="1.1.1w"
IOS_SDK_VERSION=$(xcrun -sdk iphoneos --show-sdk-version)
TVOS_SDK_VERSION=$(xcrun -sdk appletvos --show-sdk-version)

IOS_FOLDER="iPhoneOS$IOS_SDK_VERSION-arm64.sdk"
IOSSimulator_FOLDER="iPhoneSimulator$IOS_SDK_VERSION-arm64.sdk"
TVOS_FOLDER="AppleTVOS$TVOS_SDK_VERSION-arm64.sdk"
TVOSSimulator_FOLDER="AppleTVSimulator$TVOS_SDK_VERSION-arm64.sdk"

# AppleTVSimulator17.0-arm64.sdk

rm -rf openssl
rm -rf openssl-src
git clone https://github.com/jasonacox/Build-OpenSSL-cURL.git openssl-src/
cd openssl-src

./build.sh -o $OPENSSL_VERSION

cd ..
mkdir -p openssl/$IOS_FOLDER
mkdir -p openssl/$IOSSimulator_FOLDER
mkdir -p openssl/$TVOS_FOLDER
mkdir -p openssl/$TVOSSimulator_FOLDER
cp -r ./openssl-src/openssl/iOS/ ./openssl/$IOS_FOLDER/
cp -r ./openssl-src/openssl/iOS-simulator/ ./openssl/$IOSSimulator_FOLDER/
cp -r ./openssl-src/openssl/tvOS/ ./openssl/$TVOS_FOLDER/
cp -r ./openssl-src/openssl/tvOS-simulator/ ./openssl/$TVOSSimulator_FOLDER/
