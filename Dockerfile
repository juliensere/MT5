FROM node:19.0-slim
EXPOSE 3000

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied
# where available (npm@5+)
COPY package*.json ./

# If you are building your code for production
RUN npm ci --only=production

# Bundle app source
COPY . .

# Copy demo songs to a backup location for volume initialization
# This allows the entrypoint to populate an empty volume with demo content
RUN cp -r client/multitrack .multitrack-demo

# Copy and setup entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Use entrypoint to initialize multitrack volume if empty
ENTRYPOINT ["docker-entrypoint.sh"]

# Default command
CMD [ "node", "server.js" ]