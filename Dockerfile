# syntax=docker/dockerfile:experimental
FROM node:16 as base

RUN curl -f https://get.pnpm.io/v6.js | node - add --global pnpm

WORKDIR /app/

COPY . .

RUN pnpm install --frozen-lockfile --silent && \ 
  pnpm lint:fix && \
  pnpm build

######## MAIN IMAGE ########
FROM node:16-alpine as main
LABEL maintainer="daniel@woss.io" 
LABEL description="Web service for re-hosting the git repositories using the IPFS."
LABEL version="0.1.0"
LABEL repository="https://github.com/woss/ipfs-rehost-web-service"


RUN apk add --no-cache curl git \
  && curl -fsSL 'https://github.com/pnpm/pnpm/releases/download/v6.17.2/pnpm-linuxstatic-x64' -o /bin/pnpm \
  && chmod +x /bin/pnpm


WORKDIR /app

EXPOSE 3000
COPY --from=base /app/dist/server.js .
COPY --from=base /app/package.json .
COPY --from=base /app/pnpm-lock.yaml .

RUN pnpm install --frozen-lockfile --silent --production

CMD [ "node", "server.js" ]
