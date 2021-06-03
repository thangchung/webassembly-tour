# Get starting with wagi

- Build

```bash
$ rustup target add wasm32-wasi
$ cargo build-wasm
```

- Run

```
$ ./wagi --config modules.toml
```

- Test

```
# test it
$ curl -v http://localhost:3000/get-todos
```

Environment:
- Ubuntu 20.04.2 LTS
- rustc 1.52.1 (9bc8c42bb 2021-05-09)
- cargo 1.52.0 (69767412a 2021-04-21)

Happy hacking!