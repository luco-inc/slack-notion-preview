# node_modules
FROM node:16.16.0-slim AS node_modules
WORKDIR /app

ENV NODE_ENV=production

COPY ./package.json .
COPY ./yarn.lock .
RUN ls -la
RUN yarn install --frozen-lockfile --no-progress

# BASE
FROM node:16.16.0-slim AS build
WORKDIR /app

COPY . .
COPY --from=node_modules /app/node_modules ./node_modules
RUN ls -la
RUN yarn install --frozen-lockfile --no-progress
RUN yarn build

# Production Run
FROM gcr.io/distroless/nodejs:16
ENV NODE_ENV=production
WORKDIR /app

COPY --from=node_modules /app/node_modules ./node_modules
COPY --from=build /app/dist/src .

USER nonroot

EXPOSE ${PORT}

CMD ["index.js"]