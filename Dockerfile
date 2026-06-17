# Build Flutter web app and serve with nginx
FROM cirrusci/flutter:stable AS build
WORKDIR /app

# Cache dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy source and build
COPY . .
RUN flutter build web --release

FROM nginx:stable-alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
