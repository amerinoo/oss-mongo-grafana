FROM node:16-alpine AS node

WORKDIR /app

COPY . .

RUN npm install --force 
RUN npm run build 
RUN npm cache clean --force

FROM grafana/grafana:9.1.0

USER root
WORKDIR /app
#WORKDIR $GF_PATHS_PLUGINS/oss-mongodb-grafana

COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/share /usr/local/share
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

ENV GF_PATHS_PLUGINS=/grafana-plugins


# Add the source code to app
COPY --from=node /app $GF_PATHS_PLUGINS/oss-mongodb-grafana

ADD ./custom-run.sh /custom-run.sh


RUN chmod +x /custom-run.sh
RUN sed -i 's/;allow_loading_unsigned_plugins =.*/allow_loading_unsigned_plugins = oss-grafana-mongodb-datasource/g' $GF_PATHS_CONFIG

WORKDIR /app

EXPOSE 3000

ENTRYPOINT ["/custom-run.sh"]
