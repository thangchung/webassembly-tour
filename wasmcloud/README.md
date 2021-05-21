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

> On the Ubuntu VM, you need to forward port of the docker-machine guest machine into the host machine as below

```bash
# pf.sh in the tools folder, and its repo is at https://github.com/johanhaleby/docker-machine-port-forwarder
$ ./pf.sh 5000 && ./pf.sh 6379 && ./pf.sh 4222 & ./pf.sh 6222 &7 ./pf.sh 8222
```

> Push WebAssembly file with signed to Github package

```bash
# before do this, we need to login into Github package so plz follow the link https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-docker-registry
# wasm-to-oci is at https://github.com/engineerd/wasm-to-oci
$ wasm-to-oci push ../mini-store/target/wasm32-unknown-unknown/release/mini_store_s.wasm ghcr.io/thangchung/ministore:0.1.0
```

## Run with wasmtime

> it might not run well

```bash
$ rustup target add wasm32-wasi
$ cargo build --target wasm32-wasi --release
$ wasmtime target/wasm32-wasi/release/mini_store.wasm
```