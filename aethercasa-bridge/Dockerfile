ARG BUILD_FROM=ghcr.io/home-assistant/amd64-base:3.19
FROM ${BUILD_FROM}

# bashio + jq come with the HA base image.
RUN apk add --no-cache nodejs npm \
 && corepack enable || npm i -g pnpm

WORKDIR /app

# Copy pre-built bridge artifacts (dist/ + production node_modules). The CI
# workflow builds these from the monorepo before `docker build`.
COPY dist ./dist
COPY node_modules ./node_modules
COPY package.json ./package.json

COPY run.sh /run.sh
RUN chmod a+x /run.sh

ENV AETHERCASA_BRIDGE_DATA_DIR=/data
ENV AETHERCASA_INSTALL_PATH=ha-addon

CMD ["/run.sh"]
