# Etapa 1: Construção da aplicação Angular
FROM node:18 AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm install
COPY . .
RUN npm run build --prod

# Etapa 2: Servidor Node.js para servir o Angular
FROM node:18
WORKDIR /app
COPY --from=build /app/dist/angular-app /app/dist/angular-app

# Instala dependências mínimas (Express para servir o Angular)
RUN npm install express

# Servidor Node.js inline
RUN echo "const express = require('express'); \
const path = require('path'); \
const app = express(); \
const PORT = process.env.PORT || 8080; \
app.use(express.static(path.join(__dirname, '/app/dist/angular-app'))); \
app.get('*', (req, res) => { \
  res.sendFile(path.join(__dirname, '/app/dist/angular-app/index.html')); \
}); \
app.listen(PORT, () => console.log('Servidor rodando na porta', PORT));" > server.js

ENV PORT=8080
CMD ["node", "server.js"]

