https://docs.fluxy.gay/

1. Clone `https://git.fluxy.gay/dog/fluxy`
2. Pull modified Dockerfile from here
3. Build it

```bash
#> mkdir -p ~/Builder
#> git clone https://git.fluxy.gay/dog/fluxy.git
#> cd fluxy
#> curl -Lo fluxy/Modified.Dockerfile https://raw.githubusercontent.com/Rubberverse/fluxer-quadlet-bots/refs/heads/main/Fluxy/Modified.Dockerfile
#> podman build -f Modified.Dockerfile --build-arg=VITE_FLUXER_INSTANCE_API=
```

idk I got bored of writing this I'll finish it later
