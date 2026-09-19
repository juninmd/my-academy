FROM oven/bun:1.4.2-alpine AS builder
WORKDIR /usr/src/app

# Dependencies first (cacheable layer); scripts are skipped until sources exist.
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile --ignore-scripts

COPY . .
# prisma.config.ts requires DATABASE_URL at generate time; no connection is made.
ENV DATABASE_URL="postgresql://build:build@localhost:5432/build"
RUN bun run build

FROM oven/bun:1.4.2-alpine
WORKDIR /usr/src/app
ENV NODE_ENV=production
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/prisma ./prisma
COPY --from=builder /usr/src/app/package.json /usr/src/app/prisma.config.ts ./
USER bun
EXPOSE 9000
HEALTHCHECK --interval=15s --timeout=5s --retries=5 CMD wget -qO- http://localhost:9000/health || exit 1
CMD ["bun", "dist/main.js"]
