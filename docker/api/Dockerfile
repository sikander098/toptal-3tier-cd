FROM node:18-alpine

WORKDIR /app

COPY app/api/package.json ./
RUN npm install --production

COPY app/api/ ./

RUN chown -R node:node /app
USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/api/status || exit 1

CMD ["npm", "start"]
