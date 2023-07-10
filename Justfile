build:
	mkdir data
	echo "serverJar=/server/server.jar" > ./data/quilt-server-launcher.properties
	mkdir mods
	podman-compose up --detach