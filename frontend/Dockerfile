# Development stage for Flutter web
FROM ubuntu:22.04 AS development

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Flutter
ENV FLUTTER_HOME="/opt/flutter"
ENV PATH="$FLUTTER_HOME/bin:$PATH"

RUN git clone https://github.com/flutter/flutter.git $FLUTTER_HOME \
    && cd $FLUTTER_HOME \
    && git checkout stable \
    && flutter doctor

# Set working directory
WORKDIR /app

# Copy pubspec files
COPY pubspec.yaml pubspec.lock ./

# Get Flutter dependencies
RUN flutter pub get

# Copy source code
COPY . .

# Expose port for web development
EXPOSE 3000

# Default command for development
CMD ["flutter", "run", "-d", "web-server", "--web-port", "3000", "--web-hostname", "0.0.0.0"]

# Production build stage
FROM development AS builder

# Build for web
RUN flutter build web --release

# Production stage with nginx
FROM nginx:alpine AS production

# Copy built web files
COPY --from=builder /app/build/web /usr/share/nginx/html

# Remove default Nginx welcome page config (if it exists)
RUN rm -f /etc/nginx/conf.d/default.conf

# Create a simple Nginx config for serving static files from this container
RUN printf 'server {\
    listen 80;\
    server_name localhost;\
    root /usr/share/nginx/html;\
    include /etc/nginx/mime.types;\
    location / {\
        try_files $uri $uri/ /index.html;\
    }\
}' > /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"] 