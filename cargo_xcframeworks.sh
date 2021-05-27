#! /bin/sh -e
# This script demonstrates archive and create action on frameworks and libraries
#

echo "▸ Update toolchain"
rustup update

echo "▸ Install targets"
rustup target add x86_64-apple-ios
rustup target add aarch64-apple-ios
rustup target add aarch64-apple-darwin
rustup target add x86_64-apple-darwin
rustup target add aarch64-apple-ios-sim
rustup target add aarch64-apple-ios-macabi
rustup target add x86_64-apple-ios-macabi
rustup target add aarch64-apple-tvos

echo "▸ Build x86_64-apple-ios"
cargo build --target x86_64-apple-ios --package automerge-c --release

echo "▸ Build aarch64-apple-ios-sim"
xargo build --target aarch64-apple-ios-sim --package automerge-c --release

echo "▸ Build aarch64-apple-ios"
cargo build --target aarch64-apple-ios --package automerge-c --release

echo "▸ Build aarch64-apple-darwin"
cargo build --target aarch64-apple-darwin --package automerge-c --release

echo "▸ Build x86_64-apple-darwin"
cargo build --target x86_64-apple-darwin --package automerge-c --release

echo "▸ x86_64-apple-ios-macabi"
cargo build --target x86_64-apple-ios-macabi --package automerge-c --release

echo "▸ aarch64-apple-ios-macabi"
xargo build --target aarch64-apple-ios-macabi --package automerge-c --release

#echo "▸ aarch64-apple-tvos"
#xargo build --target aarch64-apple-tvos --package automerge-c --release

echo "▸ Lipo macOS"
mkdir -p ./target/apple-darwin/release
lipo -create  \
    ./target/x86_64-apple-darwin/release/libautomerge.a \
    ./target/aarch64-apple-darwin/release/libautomerge.a \
    -output ./target/apple-darwin/release/libautomerge.a

echo "▸ Lipo simulator"
mkdir -p ./target/apple-ios-simulator/release
lipo -create  \
    ./target/x86_64-apple-ios/release/libautomerge.a \
    ./target/aarch64-apple-ios-sim/release/libautomerge.a \
    -output ./target/apple-ios-simulator/release/libautomerge.a

echo "▸ Lipo ios-macabi"
mkdir -p ./target/apple-ios-macabi/release
lipo -create  \
    ./target/aarch64-apple-ios-macabi/release/libautomerge.a \
    ./target/x86_64-apple-ios-macabi/release/libautomerge.a \
    -output ./target/apple-ios-macabi/release/libautomerge.a

echo "#####################"
rm -rf ./xcframework/AutomergeRSBackend.xcframework

echo "▸ Create AutomergeRSBackend.xcframework"
  xcodebuild -create-xcframework \
            -library ./target/apple-ios-simulator/release/libautomerge.a \
            -headers ./automerge-c/Headers \
            -library ./target/aarch64-apple-ios/release/libautomerge.a \
            -headers ./automerge-c/Headers \
            -library ./target/x86_64-apple-ios-macabi/release/libautomerge.a \
            -headers ./automerge-c/Headers \
            -library ./target/apple-darwin/release/libautomerge.a \
            -headers ./automerge-c/Headers \
            -output ./xcframework/AutomergeRSBackend.xcframework
