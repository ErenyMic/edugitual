FROM node:20-alpine

WORKDIR /app

# Production by default; docker-compose overrides this for development
ARG NODE_ENV=production
ENV NODE_ENV=$NODE_ENV

COPY ./backend/package*.json ./
RUN chown -R node:node /app

# Use non-root user
USER node

# Install npm dependencies
# Requires package-lock.json to exist
# In development, devDependencies will also be installed
RUN npm ci && npm cache clean --force

# Verify NestJS CLI is available in development
RUN if [ "$NODE_ENV" = "development" ]; then \
      npx nest --version || (echo "NestJS CLI not found!" && exit 1); \
    fi

# Copy remaining files for build
COPY --chown=node:node ./backend/tsconfig*.json ./
COPY --chown=node:node ./backend/nest-cli.json ./
COPY --chown=node:node ./backend/src ./src/
COPY --chown=node:node ./shared ./shared/

# Optional Prisma setup (uncomment if needed)
# COPY ./backend/prisma ./prisma/
# RUN npx prisma generate

# Production build
RUN if [ "$NODE_ENV" = "production" ]; then npm run build; fi

EXPOSE 3000

# Default command for production (overridden by docker-compose for development)
CMD ["node", "dist/main.js"]
