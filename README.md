# mpv iOS build scripts

This is a macOS shell script for cross-compiling [libmpv](https://github.com/mpv-player/mpv), and its dependencies:

- FFmpeg
- libass
- freetype
- harfbuzz
- fribidi
- uchardet

## Configuration

Tested with:

- macOS 14.0
- Xcode 15.0

## Brew

https://gist.github.com/dbrookman/74b8bcfb37a23452f7137b83bca9580f

```
brew install pkg-config brotli
brew install --build-from-source --only-dependencies mpv
```

## 使用

1. 運行 `./install-openssl.sh` 以生成 tvOS / iOS 所需的 openssl。
2. 運行 `./clean.sh && ./download.sh` 執行清理、下載的步驟。
3. 運行 `./build.sh` 即可開始 Build 的過程。
4. 運行 `./xcframework.sh` 即可構建 xcframework 庫。

`build.sh` 存在一個 Bug，第一次下載構建時候會失敗，重新執行即可。

本腳本移除了 x86_64 的框架支持。

如果需要更新 openssl 版本號，修改 `install-openssl.sh` 中的 version 即可。
並非所有的 openssl 版本號都可用，最後測試 1.1.1w 可正常通過編譯。
如若遇到缺少 gas-preprocessor 提示，請執行 `install-gas-preprocessor.sh`

## 最小版本號問題

https://juejin.cn/post/7182833413835980859

追加了最小版本號：15.1
修改最小版本號需要修改兩個地方：

1. `framework-meta/Info.plist` 把 MinimumOSVersion 改成所需要的值。
2. `xcframework.sh` 把 Add :MinimumOSVersion string 15.1 的 15.1 改成所需要的值。

## Download 版本

更新最適配的版本 mpv 0.35.1 + ffmpeg 6.0

## Diff patch

`diff -u a.file b.file > patch.diff`
`diff -Nur ./src/mpv-0.35.1-b/ ./src/mpv-0.35.1/ > patch-mpv.diff`
`rm -rf scratch-ios scratch-tv && ./compile.sh -p tv -e development`
