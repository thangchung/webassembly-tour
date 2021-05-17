# Installation

Install on Windows Sub-system

```bash
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
$ curl -s https://packagecloud.io/install/repositories/wasmcloud/core/script.deb.sh | sudo bash
$ sudo apt install wasmcloud wash
$ curl https://wasmtime.dev/install.sh -sSf | bash
```

# Build

## Step by step to run mini_store

```bash
$ rustup target add wasm32-unknown-unknown
$ cargo build --target wasm32-unknown-unknown --release
$ wash claims sign target/wasm32-unknown-unknown/release/mini_store.wasm --http_server --name "ministore" --ver 0.1.0 --rev 0
$ wash claims inspect target/wasm32-unknown-unknown/release/mini_store_s.wasm
```

Make sure you run `docker-compose up` to start the `registry`, `redis`, and `nats` before execute the following command

```bash
$ wash reg push localhost:5000/ministore:0.1.0 target/wasm32-unknown-unknown/release/mini_store_s.wasm --insecure
```

Create [`manifest.yaml`](mini-store/manifest.yaml) with content as below

```yaml
labels:
  actor: "ministore"
actors:
  - "localhost:5000/ministore:0.1.0"
capabilities:
  - image_ref: wasmcloud.azurecr.io/httpserver:0.12.1
    link_name: default
links:
  - actor: ${CLIENT_ACTOR:<your Mudule Id from `wash claims inspect target/wasm32-unknown-unknown/release/mini_store_s.wasm` above>}
    provider_id: "VAG3QITQQ2ODAOWB5TTQSDJ53XK3SHBEIFNK4AYJ5RKAX2UNSCAPHA5M"
    contract_id: "wasmcloud:httpserver"
    link_name: default
    values:
      PORT: 8080
```

Then

```bash
$ wasmcloud --allowed-insecure localhost:8080 -m manifest.yaml
```

Finally, you can run

```bash
$ curl localhost:8080/add?5,5 --output -
```

## Run with wasmtime

> it might not run well

```bash
$ cargo build --target wasm32-wasi --release
$ wasmtime target/wasm32-wasi/release/mini_store.wasm
```