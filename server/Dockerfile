# NOT VERIFIED: written without Docker available (Sprint 010, PBI-063b).
# Build context is the repository root:
#   docker build -f server/Dockerfile -t suitestream:local .
# Pin both images to exact tags before a real release.
ARG FLUTTER_IMAGE=ghcr.io/cirruslabs/flutter:stable
ARG DART_IMAGE=dart:stable

# 1. Flutter web build
FROM ${FLUTTER_IMAGE} AS web
WORKDIR /src
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY analysis_options.yaml ./
COPY assets ./assets
COPY lib ./lib
COPY web ./web
RUN flutter build web --release --no-web-resources-cdn

# 2. Server, ahead-of-time compiled
FROM ${DART_IMAGE} AS server
WORKDIR /app
COPY server/pubspec.yaml server/pubspec.lock ./
RUN dart pub get
COPY server/bin ./bin
COPY server/lib ./lib
RUN dart pub get --offline && dart compile exe bin/server.dart -o /app/server

# 3. Runtime: the Dart runtime files (includes CA certificates for HTTPS to
# Authentik), the server executable and the web build. No shell, no curl.
FROM scratch
COPY --from=server /runtime/ /
COPY --from=server /app/server /app/server
COPY --from=web /src/build/web /app/web
ENV WEB_DIR=/app/web PORT=8080
EXPOSE 8080
USER 65532:65532
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD ["/app/server", "--healthcheck"]
ENTRYPOINT ["/app/server"]
