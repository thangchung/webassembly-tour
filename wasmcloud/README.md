# Installation

Install on Windows Sub-system

```bash
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
$ curl -s https://packagecloud.io/install/repositories/wasmcloud/core/script.deb.sh | sudo bash
$ sudo apt install wasmcloud wash
$ curl https://wasmtime.dev/install.sh -sSf | bash
```

# Build

Build `wasm` file

```bash
$ cargo build --target wasm32-wasi --release
$ wasmtime target/wasm32-wasi/release/mini_store.wasm
```