# --- Day 2: basic Dockerfile ---
# Using a slim base image keeps the final image small (Day 3 optimization)
FROM node:20-alpine

# Set working directory inside the container
WORKDIR /app

# Copy only package files first so Docker can cache the npm install layer
COPY package*.json ./
# RUN npm install --omit=dev
RUN npm ci --omit=dev

# Copy the rest of the app
COPY . .

# The app listens on this port (see index.js)
EXPOSE 3000

# Day 6: basic healthcheck so Docker knows if the app is alive
# HEALTHCHECK --interval=30s --timeout=3s \
#  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

# Day 5: PORT can be overridden via environment variable
# ENV PORT=3000

# Day 5: PORT can be overridden via environment variable
ENV PORT=3000

# Day 6: healthcheck follows the PORT variable
HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:${PORT}/health || exit 1

CMD ["node", "index.js"]
