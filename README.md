Problems:
- Using bind mounts instead of Docker volumes - we need to change the server
  configuration (for example, the `server.properties` file). We cannot do
  it from inside the container since it doesn't have a shell. Therefore, since
  we shouldn't change Docker volumes from outside the container, it's better
  for us to do a bind mount.
- The container is running as root - [bind mounts don't play nicely with
  nonroot users](https://github.com/moby/moby/issues/2259). Since we're running
  in a distroless image, we can't run `chmod` to fix this :) This is less of an
  issue since this is a distroless image, but it's recommended to use
  [podman](https://podman.io/) instead of Docker to run the container itself
  without root on your system.
- It doesn't fully enforce [W^X](https://en.wikipedia.org/wiki/W%5EX) - the
  `libraries` and `versions` folder contain jar files. However, this code needs
  to be in the data folder and is generated by the server, so
    - we could generate these folders from the server, put them in the data
      folder, freeze these in the image, and then manually bind mount each file
      from the host data folder into the container - but this means we need to
      *define* each file from the data folder! We can't use the server's default
      values and it's a pain that isn't futureproof. If the server adds/removes
      files or defaults in the future, we wouldn't capture it.
    - Or, we let `libraries` and `versions` be W&X. Lame, but at least `mods`
    and the root server jar file is protected.