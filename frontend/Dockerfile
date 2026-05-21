# Base image: node:20-alpine
FROM node:20-alpine

# WORKDIR: /app
WORKDIR /app

# COPY package.json and package-lock.json first (layer cache optimization)
COPY package.json package-lock.json* ./

# Install npm dependencies
RUN npm install

# COPY all source files
COPY . .

# Expose Next.js default port
EXPOSE 3000

# Dev mode with hot reload via volume mount
# CMD to run the development server
CMD ["npm", "run", "dev"]
