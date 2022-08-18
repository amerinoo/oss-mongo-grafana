FROM node:16-alpine AS node

FROM grafana/grafana:9.1.0

USER root
WORKDIR $GF_PATHS_PLUGINS

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Add the package.json
COPY ./package*.json ./

# Install all the dependencies
RUN npm install --force

# Add the source code to app
COPY . .

# Generate the build of the application
RUN npm run build

RUN apk update \
    && apk upgrade  \
    && mv dist $GF_PATHS_PLUGINS/oss-mongodb-grafana \
    && npm cache clean --force --prefix $GF_PATHS_PLUGINS/oss-mongodb-grafana \
    && chmod +x custom-run.sh \
    && sed -i 's/;allow_loading_unsigned_plugins =.*/allow_loading_unsigned_plugins = oss-grafana-mongodb-datasource/g' $GF_PATHS_CONFIG

EXPOSE 3000

ENTRYPOINT ["./custom-run.sh"]