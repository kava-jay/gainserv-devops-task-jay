FROM node:22-alpine AS dependencies

WORKDIR /app

COPY app/package.json app/package-lock.json ./

# --omit=dev excludes development dependencies.
# --ignore-scripts prevents dependency lifecycle scripts from running during installation.
RUN npm ci --omit=dev --ignore-scripts && \
    npm cache clean --force

FROM node:22-alpine AS runtime

ENV NODE_ENV=production
ENV PORT=3000

WORKDIR /app

COPY --from=dependencies --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node app/package.json app/server.js ./

# USER node runs the application as a non-root user.
USER node 

EXPOSE 3000

CMD ["node", "server.js"]
