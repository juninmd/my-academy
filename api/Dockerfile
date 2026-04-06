FROM node:22-alpine AS builder
WORKDIR /usr/src/app

# Instala dependências primeiro (layer cacheável)
# --ignore-scripts evita que o postinstall rode `pnpm run build`
# antes de copiar o código-fonte
COPY package.json pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install --frozen-lockfile --ignore-scripts

# Copia código e gera o Prisma client + compila TypeScript
COPY . .
RUN pnpm run build

FROM node:22-alpine
WORKDIR /usr/src/app
COPY --from=builder /usr/src/app/dist ./dist
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY --from=builder /usr/src/app/package.json ./
COPY --from=builder /usr/src/app/prisma ./prisma
EXPOSE 9000
CMD ["node", "dist/src/main.js"]
