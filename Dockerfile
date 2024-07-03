# Use a lightweight Node.js base image
FROM node:18-alpine3.18

# Install build dependencies (adjust based on your project)
RUN apk update && apk add --no-cache build-base gcc autoconf automake zlib-dev libpng-dev nasm bash vips-dev git

# Set working directory
WORKDIR /opt/app

# Copy package.json and yarn.lock
COPY package.json yarn.lock ./

# Install global node-gyp for native dependencies (if needed)
RUN yarn global add node-gyp

# Increase network timeout for installations
RUN yarn config set network-timeout 600000 -g

# Install dependencies
RUN yarn install

# Set path to include node_modules/.bin
ENV PATH /opt/node_modules/.bin:$PATH

# Copy remaining project files
COPY . .

# Change ownership for node user
RUN chown -R node:node /opt/app

# Switch user to node for running the application
USER node

# Expose Strapi port (usually 1337)
EXPOSE 1337

# Run Strapi in development mode (replace with your command for production)
CMD ["yarn", "develop"]

