FROM node:22-alpine AS base

RUN corepack enable && corepack prepare pnpm@10.12.1 --activate

WORKDIR /app

FROM base AS deps

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json tsconfig.base.json ./
COPY apps/web/package.json apps/web/
COPY packages/app/package.json packages/app/
COPY packages/domain/package.json packages/domain/
COPY packages/platform/package.json packages/platform/
COPY packages/platform-web/package.json packages/platform-web/

RUN pnpm install --frozen-lockfile --filter @labword/web...

FROM deps AS build

COPY apps/web apps/web
COPY packages packages

RUN pnpm --filter @labword/web build

FROM nginx:1.27-alpine AS runtime

COPY docker/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/apps/web/dist /usr/share/nginx/html

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget -qO- http://127.0.0.1/ || exit 1
