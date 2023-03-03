#! /bin/sh -e
# This script demonstrates archive and create action on frameworks and libraries
#

echo "▸ Update toolchain"
rustup update

echo "x86_64-apple-ios-macabi and aarch64-apple-ios-macabi require the nightly toolchain"
rustup toolchain install nightly
rustup default nightly

# to allow for abi builds from the nightly toolchain for xargo...
rustup component add rust-src

echo "▸ Install xargo"
cargo install xargo

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
xargo build -Zbuild-std --target aarch64-apple-ios-sim --package automerge-c --release

echo "▸ Build aarch64-apple-ios"
cargo build --target aarch64-apple-ios --package automerge-c --release

echo "▸ Build aarch64-apple-darwin"
cargo build --target aarch64-apple-darwin --package automerge-c --release

echo "▸ Build x86_64-apple-darwin"
cargo build --target x86_64-apple-darwin --package automerge-c --release

# echo "▸ x86_64-apple-ios-macabi"
# xargo build -Zbuild-std --target x86_64-apple-ios-macabi --package automerge-c --release

# echo "▸ aarch64-apple-ios-macabi"
# #xargo build --target aarch64-apple-ios-macabi --package automerge-c --release
# xargo build -Zbuild-std --target aarch64-apple-ios-macabi --package automerge-c --release

# echo "▸ aarch64-apple-tvos"
# xargo build -Zbuild-std --target aarch64-apple-tvos --package automerge-c --release
# multiple errors when building the std. library for tvOS w/ nightly

echo "▸ Lipo macOS"
mkdir -p ./target/apple-darwin/release
lipo -create  \
    ./target/x86_64-apple-darwin/release/libautomerge_core.a \
    ./target/aarch64-apple-darwin/release/libautomerge_core.a \
    -output ./target/apple-darwin/release/libautomerge_core.a

echo "▸ Lipo simulator"
mkdir -p ./target/apple-ios-simulator/release
lipo -create  \
    ./target/x86_64-apple-ios/release/libautomerge_core.a \
    ./target/aarch64-apple-ios-sim/release/libautomerge_core.a \
    -output ./target/apple-ios-simulator/release/libautomerge_core.a

echo "▸ Lipo ios-macabi"
mkdir -p ./target/apple-ios-macabi/release
lipo -create  \
    ./target/aarch64-apple-ios-macabi/release/libautomerge_core.a \
    ./target/x86_64-apple-ios-macabi/release/libautomerge_core.a \
    -output ./target/apple-ios-macabi/release/libautomerge_core.a

echo "#####################"
rm -rf ./xcframework/AutomergeBackend.xcframework

mkdir -p automerge-swift-backend/Headers
cp ./automerge-c/build/include/automerge-c/automerge.h automerge-swift-backend/Headers
cp automerge-swift-backend/module.modulemap automerge-swift-backend/Headers

echo "▸ Create AutomergeRSBackend.xcframework"
  xcodebuild -create-xcframework \
            -library ./target/apple-ios-simulator/release/libautomerge_core.a \
            -headers ./automerge-swift-backend/Headers \
            -library ./target/aarch64-apple-ios/release/libautomerge_core.a \
            -headers ./automerge-swift-backend/Headers \
            -library ./target/apple-darwin/release/libautomerge_core.a \
            -headers ./automerge-swift-backend/Headers \
            -output ./xcframework/AutomergeBackend.xcframework

  # -library ./target/apple-ios-macabi/release/libautomerge_core.a \
  # -headers ./automerge-swift-backend/Headers \


echo "▸ Compress AutomergeRSBackend.xcframework"
ditto -c -k --sequesterRsrc --keepParent ./xcframework/AutomergeBackend.xcframework ./automerge-swift-backend/AutomergeBackend.xcframework.zip

echo "▸ Compute AutomergeRSBackend.xcframework checksum"
cd automerge-swift-backend
swift package compute-checksum ./AutomergeBackend.xcframework.zip
