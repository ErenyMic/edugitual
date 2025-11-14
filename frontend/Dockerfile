FROM node:20-alpine

WORKDIR /app

# Production by default; docker-compose overrides this for development
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

COPY ./frontend/package*.json ./
RUN chown -R node:node /app

USER node

# Install npm dependencies
RUN npm ci && npm cache clean --force

# Copy configuration files
COPY --chown=node:node ./frontend/vite.config.ts ./
COPY --chown=node:node ./frontend/tsconfig*.json* ./
COPY --chown=node:node ./frontend/index.html* ./

# Copy source code
COPY --chown=node:node ./frontend/src ./src/
COPY --chown=node:node ./frontend/public* ./public/

# Copy shared types
COPY --chown=node:node ./shared ./shared/

# Production build
RUN if [ "$NODE_ENV" = "production" ]; then npm run build; fi

EXPOSE 5173

# Default command for production (nginx could serve dist/)
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]
