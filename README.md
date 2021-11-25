# Automerge Swift Backend

This directory contains the script and components needed to generate an XCFramework that allows the Apple platforms to link and use the [backend for Automerge, implemented in Rust](https://github.com/automerge/automerge-rs).

## Prerequisites

Install Xcode and the Rust programming language.

The Rust programming language doesn't have `std` library support pre-built and available for some of the platforms in the `stable` branch, so to build this library you'll need to use `nightly`.

You can change the default tooling using the command:

`rustup default nightly`

## To generate an XCFramework

1. Clone the [automerge-rs]((https://github.com/automerge/automerge-rs)) onto your local machine.

2. Change the working directory to `automerge-rs`, then clone this repository into its top level directory. You should end up with `automerge-rs/automerge-swift-backend`.

3. Run the command `sh automerge-swift-backend/cargo_xcframeworks.sh` from the top level of the automerge-rs.

The script adds the relevant targets, installs [`xargo`](https://github.com/japaric/xargo#xargo) to build the relevant platform sysroots, and builds the code for the various platforms. After the platforms are built, the script combines the individual static libraries into fat libraries for the framework, and then compiles the framework.

The generated framework resides in the `xcframework` directory.
