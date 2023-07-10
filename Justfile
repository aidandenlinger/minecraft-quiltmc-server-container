build:
	mkdir server
	echo "serverJar=/server/server.jar" > ./server/quilt-server-launcher.properties
	mkdir mods
	podman-compose up --detach