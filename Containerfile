ARG MINECRAFT_VERSION

FROM eclipse-temurin:17 AS build
# Bring the argument into build
ARG MINECRAFT_VERSION

# Download the quilt installer and put the jars in server/
RUN wget -O quilt-installer.jar \
    https://quiltmc.org/api/v1/download-latest-installer/java-universal \
  && java -jar quilt-installer.jar \
    install server $MINECRAFT_VERSION \
    --download-server

FROM gcr.io/distroless/java17-debian11
COPY --from=build /server /server

# Expose the default port for a minecraft server
EXPOSE 22565/tcp
EXPOSE 22565/udp

# This is a mounted folder that is on the host machine
# Holds server data
# Use a bind mount for easy configuration
WORKDIR /data

# https://quiltmc.org/en/blog/2023-06-26-mau-beacon/
# Means it won't try to write to the .config directory
ENV QUILT_LOADER_DISABLE_BEACON=true

CMD ["/server/quilt-server-launch.jar", "nogui"]
# ENTRYPOINT ["sh"]