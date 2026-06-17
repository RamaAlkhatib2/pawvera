# Build Flutter web app and serve with nginx
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

# Install git (required for many pub packages)
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y git --no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# Copy pubspec files first to leverage Docker layer caching
# Use a glob so `pubspec.lock` being absent doesn't make COPY fail.
COPY pubspec.* ./
RUN if [ ! -f pubspec.lock ]; then touch pubspec.lock; fi
RUN flutter pub get

# Copy rest of the source and build for web
COPY . .
RUN flutter build web --release

FROM nginx:stable-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
