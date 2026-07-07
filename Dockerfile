# Stage 1: Build stage
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package descriptors and install all dependencies
COPY package*.json ./
RUN npm ci

# Copy full application code and compile
COPY . .
RUN npm run build

# Stage 2: Production runner stage
FROM node:20-alpine AS runner

WORKDIR /app

# Set environment to production
ENV NODE_ENV=production

# Copy compiled assets, server bundle and configuration from builder
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./

# Install only production dependencies to minimize image size and increase security
RUN npm ci --omit=dev

# Expose Hugging Face's standard port (7860) or any container port
EXPOSE 7860

# Launch server
CMD ["node", "dist/server.cjs"]
