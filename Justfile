up:
	podman-compose up --detach

down:
	podman-compose down

attach:
	podman attach quiltmc-server-container_quilt-server_1

install:
	if [ -d data ]; then mv data data-backup; fi
	cp -r data-template data
	podman-compose build