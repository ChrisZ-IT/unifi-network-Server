FROM ubuntu:26.04
ARG UNIFI_VER="10.5.67"
ARG MONGODB_VER="8.0"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    gnupg \
    ca-certificates \
    apt-transport-https \
    gpg; \
    curl -fsSL https://pgp.mongodb.com/server-$MONGODB_VER.asc | gpg -o /usr/share/keyrings/mongodb-server-$MONGODB_VER.gpg --dearmor \
    && echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-$MONGODB_VER.gpg ] https://repo.mongodb.org/apt/ubuntu noble/mongodb-org/$MONGODB_VER multiverse" | \
    tee /etc/apt/sources.list.d/mongodb-org-$MONGODB_VER.list \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && curl "https://dl.ui.com/unifi/$UNIFI_VER/unifi_sysvinit_all.deb" -o /tmp/unifi.deb \
    && apt-get install -y --no-install-recommends /tmp/unifi.deb \
    && rm /tmp/unifi.deb \
    && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["java", "-jar", "/usr/lib/unifi/lib/ace.jar", "start"]