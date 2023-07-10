build:
	mkdir server
	echo "serverJar=/server/server.jar" > ./server/quilt-server-launcher.properties
	podman-compose up --detach