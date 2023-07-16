up:
	podman-compose up --detach

down:
	podman-compose down

logs:
	podman-compose logs

install:
	if [ -d data ]; then mv data data-backup; fi
	cp -r data-template data
	for file in data/*/.keep; do rm $file; done
	podman-compose build

update:
	podman-compose build --pull --no-cache
	podman image prune

attach:
	podman attach minecraft-quiltmc-server-container_quilt-server_1
