FROM node:20-alpine

ENV NODE_ENV=production

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar solo dependencias de producción
RUN npm ci --omit=dev && npm cache clean --force

# Copiar código de la aplicación
COPY src/ ./src/
COPY sql/ ./sql/

# Crear directorio para uploads y entregarlo al usuario sin privilegios
RUN mkdir -p uploads/documentos && chown -R node:node /app/uploads

# Ejecutar como usuario no-root
USER node

# Puerto interno (solo accesible dentro de la red de Docker)
EXPOSE 4000

HEALTHCHECK --interval=30s --timeout=5s --start-period=15s --retries=3 \
  CMD wget -qO- http://127.0.0.1:4000/ || exit 1

# Comando para iniciar la aplicación
CMD ["node", "src/app.js"]
