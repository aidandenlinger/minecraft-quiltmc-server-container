# QuiltMC Server Container _(minecraft-quiltmc-server-container)_

Sandbox a QuiltMC Minecraft server in a container/docker!

## Background

Any software can be attacked and exploited - recent events in the Minecraft
community like
[log4j](https://help.minecraft.net/hc/en-us/articles/4416199399693) and
[fractureiser](https://github.com/fractureiser-investigation/fractureiser)
have made it clear that Minecraft servers and mods can be targets for attackers.
Isolating and sandboxing the Minecraft server can reduce the severity of such
attacks by limiting the server's ability to run code or access external data.
Without bypassing the container's sandbox, it can't read any data besides
the server data, and all java code is either read-only or will be reset upon
a container restart (so any tampering with .jar files should not have any
impact). *Please note that this is an improvement compared to just running
the server, but it is not a perfect solution!* Containers can have their own
vulnerabilities.

There are several other minecraft server containers, but I couldn't find one
using QuiltMC that primarily focused on security (limiting permissions,
file-grained permissions, distroless images, etc).

[QuiltMC](https://quiltmc.org/en/) is an open-source mod loader for Minecraft.
It can be installed on the Minecraft server to allow for installation of mods,
which this container will do. At the time of writing, it is compatible with
[Fabric](https://fabricmc.net/) mods. It's well suited for playing with a couple
of friends - if you're intending to host many players, you should look into
[PaperMC](https://papermc.io/) and related projects like
[Purpur](https://purpurmc.org/) and [Pufferfish](https://pufferfish.host/),
which stray a bit from vanilla Minecraft behavior in exchange for performance
and stability. Be sure to look at what the current state-of-the-art is though!
The [admincraft community](https://discord.gg/DxrXq2R) has been very helpful.

### Techniques

> **Warning**
> I'm not a security expert! There may be massive oversights. This should be
> an improvement compared to just running the server, but do not treat this
> as a perfect solution.

This technique relies on
[containerization](https://en.wikipedia.org/wiki/Containerization_(computing)).
We put the server in its own limited computing environment, where the
container software (like [Podman](https://podman.io/) or
[Docker](https://www.docker.com/)) limits the environment to only running the
server and accessing server files. The container is built on a [distroless
image from Google](https://github.com/GoogleContainerTools/distroless#readme),
which means it does not have a shell (`bash`, `sh`, etc) or a package manager
(`apt`, `dnf`, etc), drastically reducing attack surface. We also limit the
computer resources the server can use, make as much data read-only as we can,
and drop all capabilities.

The current weaknesses are that the image is running as root and we are using
bind mounts instead of a volume - please see the [Contributing](#contributing)
section for more.

If you're interested, please read more about container hardening at
[Wonderfall's blog](https://wonderfall.dev/docker-hardening/), which was the
main resource I used in creating this (along with plenty of container
documentation like [the compose
spec](https://github.com/compose-spec/compose-spec) and the [Containerfile
man page](https://www.mankier.com/5/Containerfile)).

### Minecraft Server

You're expected to understand how to run a Minecraft server. Please
read [this wiki
article](https://minecraft.gamepedia.com/Tutorials/Setting_up_a_server) if
you're unfamiliar. If you want your server to be accessible to the internet,
please read the section about port forwarding carefully.

## Install

### Dependencies
You'll need software for containerization - on Linux, I'd highly recommend
[podman](https://podman.io/docs/installation) and
[podman-compose](https://github.com/containers/podman-compose#installation)
and running the containers as a non-root user. If you're on Mac or Windows,
you will likely find installing [Podman
Desktop](https://github.com/containers/podman-desktop) to be easier. However,
please note that the rest of the instructions will assume you're running on
Linux. Podman is recommended since Docker runs the containers as root, and as
such any attacker that escapes the container would not have root privileges.

If you prefer Docker, you can also install and use [Docker
Desktop](https://docs.docker.com/desktop/) - this comes with docker and docker
compose.

You can optionally install [Just](https://github.com/casey/just) to use the
Justfile if you're using podman - it's optional though, you can look inside the
file to see the commands to run.

### Building the Container

> **Note**
> This Containerfile will download a Minecraft server jar. This notice appears
> on <https://www.minecraft.net/en-us/download/server>:
>
> Just so you know, by downloading any of the software on this page, you agree
> to the 
> [Minecraft End User License Agreement](https://account.mojang.com/documents/minecraft_eula)
> and [Privacy Policy](https://go.microsoft.com/fwlink/?LinkId=521839).

Due to this, I'm a bit uncomfortable posting an entire image and hosting
Mojang's code, so I'm pushing the installation to you.

Clone this repo. If you have [Just](https://github.com/casey/just), you can
run `just install`. Otherwise, make a copy the `data-template` folder, name it
`data`, optionally remove the `.keep` file in any folders in `data`, then run
`podman-compose build` or `docker compose build`. It will download the quilt
installer and create the server image. You should also be able to choose the
repo and build it in Podman/Docker Desktop.

## Usage

Take a look at the `compose.yaml` file and change it to your liking. Most
importantly, set the MINECRAFT_VERSION, change `deploy.resources.limits` to the
limits you want, and change the ports if desired!

To run the image, run `just up` or `podman-compose up --detach` or `docker
compose up --detach`. This will start the server. The server will then stop
because you need to agree to the EULA - run `just down` / `podman-compose
down` / `docker compose down`, then go to the `data` folder, agree to the EULA,
establish your settings in `server.properties`, put any Quilt/Fabric mods in
the `mods` folder, do any other adminstration work, and put the server back
up! You should be able to connect to it from your local machine with the server
name `localhost`, or use your local IP to connect to it on a local network, or a
public IP if you've port forwarded.

To stop it, do `just down` / `podman-compose down` / `docker compose down`.
You can see the logs with `just logs` / `podman-compose logs` / `docker compose
logs`. To attach to the server, you can use the Justfile or note the name of the
container in `podman container ls` / `docker container ls` (with podman-compose
it should be quiltmc-server-container_quilt-server_1) and then you can perform
actions like `attach` (which will open a terminal session to run commands on the
server like `op` or `whitelist`).

All data is stored in the `data` folder. Remember to back up this folder, as it
holds all your server data!

At least once a week, you should update your server image by running `just
update` / `podman-compose build --pull --no-cache` / `docker compose build
--pull --no-cache`. This will pull the latest images (including the latest Java
version and distro fixes). You can also run `podman image prune` / `sudo docker
image prune` after an update to remove unneeded images.

## Contributing
These are the current remaining problems. I'm not intending on working on these
unless a splash of inspiration hits me, but I'd be more than happy to accept
any PRs dealing with these:

- We're using bind mounts instead of Docker volumes - we need to be able to
  change the server configuration (for example, the `server.properties` file).
  We cannot do it from inside the distroless container since it doesn't have a
  shell. Therefore, since we shouldn't change Docker volumes from outside the
  container, it's better for us to do a bind mount.
- However, since we're using a bind mount, the container is running as root -
  [bind mounts don't play nicely with nonroot
  users](https://github.com/moby/moby/issues/2259). Since we're running in a
  distroless image, we can't run `chmod` to fix this :) This is less of an issue
  since this is a distroless image so being root does not enable much more, but
  it's recommended to use [podman](https://podman.io/) instead of Docker to run
  the container itself without root on your system.

## License
MIT
