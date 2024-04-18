ARG MINECRAFT_VERSION

FROM docker.io/library/eclipse-temurin:22-jre-alpine AS build
# Bring the argument into build
ARG MINECRAFT_VERSION

# Download the quilt installer and put the jars in server/
RUN wget -O quilt-installer.jar \
    https://quiltmc.org/api/v1/download-latest-installer/java-universal \
  && java -jar quilt-installer.jar \
    install server $MINECRAFT_VERSION \
    --download-server

# Now, we're gonna generate the libraries and versions jars by running the
# server once
WORKDIR /data
RUN echo "serverJar=/server/server.jar" > quilt-server-launcher.properties \
    && java -jar /server/quilt-server-launch.jar nogui > /dev/null

FROM gcr.io/distroless/java17-debian12
WORKDIR /data
# Copy all jars over! They will be *readonly* within this image :)
COPY --from=build /server /server
# Bad form to have several copies, but I don't want to copy all of data
COPY --from=build /data/libraries /data/libraries
COPY --from=build /data/versions /data/versions
COPY --from=build /data/quilt-server-launcher.properties /data/quilt-server-launcher.properties

# Expose the default port for a minecraft server
EXPOSE 22565/tcp
EXPOSE 22565/udp

CMD ["/server/quilt-server-launch.jar", "nogui"]
