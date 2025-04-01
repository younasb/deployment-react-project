# Stage 1: Build the React/Vite application
FROM node:20-alpine AS builder
# 'alpine' variants are smaller base images
# Use 'AS builder' to name this stage

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock)
COPY package*.json ./

# Install dependencies using 'ci' for reproducibility
RUN npm ci

# Copy the rest of the application source code
COPY . .

# Run the build command defined in your package.json
RUN npm run build
# This should create a 'dist' directory (or similar based on your vite.config.js)

# Stage 2: Set up the Nginx server to serve the built files
FROM nginx:stable-alpine
# Use a stable, small Nginx image

# Copy the built static files from the 'builder' stage to the Nginx web root
# Ensure '/app/dist' matches the output directory of your 'npm run build' command
COPY --from=builder /app/dist /usr/share/nginx/html

# (Optional but Recommended for React Router/SPAs) Copy a custom Nginx configuration
# This ensures that client-side routing works correctly by redirecting all requests
# to index.html if a specific file/directory isn't found.
# COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 (the default port Nginx listens on)
EXPOSE 80

# The default command for the nginx base image is usually sufficient,
# but you can be explicit: starts nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]