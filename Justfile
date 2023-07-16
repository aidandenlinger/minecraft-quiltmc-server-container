up:
	podman-compose up --detach

down:
	podman-compose down

logs:
	podman-compose logs

install:
	if [ -d data ]; then mv data data-backup; fi
	cp -r data-template data
	podman-compose build

update:
	podman-compose build --pull

attach:
	podman attach quiltmc-server-container_quilt-server_1
