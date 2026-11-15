# syntax=docker/dockerfile:1
# Modified Dockerfile to chown as node:node, run the container as node user, remove entrypoint.sh and make ARGs passable by podman build.
# This is otherwise unmodified

FROM node:24-bookworm-slim AS base
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates fontconfig \
  && rm -rf /var/lib/apt/lists/*
RUN corepack enable && corepack prepare pnpm@11.6.0 --activate
WORKDIR /app

FROM base AS build
COPY . .
RUN pnpm install --frozen-lockfile
RUN pnpm run build
WORKDIR /app/dashboard
ARG VITE_FLUXER_INSTANCE_API \
    VITE_FLUXER_INSTANCE_WEB \
    VITE_FLUXER_INSTANCE_MEDIA \
    VITE_FLUXER_CLIENT_ID
RUN printf 'VITE_MOCK_MODE=false\nVITE_FLUXER_INSTANCE_API=%s\nVITE_FLUXER_INSTANCE_WEB=%s\nVITE_FLUXER_INSTANCE_MEDIA=%s\nVITE_FLUXER_CLIENT_ID=%s\n' \
  "$VITE_FLUXER_INSTANCE_API" "$VITE_FLUXER_INSTANCE_WEB" "$VITE_FLUXER_INSTANCE_MEDIA" "$VITE_FLUXER_CLIENT_ID" > .env.production
RUN pnpm run build
WORKDIR /app
ENV CI=true
RUN pnpm prune --prod --ignore-scripts

FROM base AS runtime
ENV NODE_ENV=production
WORKDIR /app

COPY --from=build --chown=node:node /app/package.json /app/pnpm-lock.yaml /app/pnpm-workspace.yaml ./
COPY --from=build --chown=node:node /app/node_modules ./node_modules
COPY --from=build --chown=node:node /app/build ./build
COPY --from=build --chown=node:node /app/dashboard/dist ./dashboard/dist
COPY --from=build --chown=node:node /app/scripts/preflight-slot.js ./scripts/preflight-slot.js
COPY --from=build /app/.forgejo/.shrek ./.forgejo/.shrek

USER node:node
EXPOSE 4000 4001
ENTRYPOINT ["node", "build/index.js"]
