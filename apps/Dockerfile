#################
##### Arguments
ARG APP=""
ARG ARCH="x86_64"

################
##### Builder
FROM rust:1.91.0 AS builder
ARG APP
ARG ARCH

ENV PKG_CONFIG_ALLOW_CROSS=1

## Install musl dependencies
## Install target platform (Cross-Compilation) --> Needed for Alpine
RUN apt-get update  \
    && apt-get --no-install-recommends install musl-tools build-essential protobuf-compiler -y \
    && rustup target add $ARCH-unknown-linux-musl

# Set the working directory
WORKDIR /usr/src/$APP

# Copy the root Cargo.toml and Cargo.lock files first
COPY ./Cargo.toml ./Cargo.lock ./

# Modules
COPY grpcapi-client/Cargo.toml grpcapi-client/
COPY wsapi-client/Cargo.toml wsapi-client/

# Applications
COPY apps/rapi/Cargo.toml apps/rapi/
COPY apps/grpcapi/Cargo.toml apps/grpcapi/
COPY apps/wsapi/Cargo.toml apps/wsapi/


# Now copy the rest of the source code
COPY ./apps ./apps
COPY ./grpcapi-client ./grpcapi-client
COPY ./wsapi-client ./wsapi-client
COPY ./proto ./proto
# FIXME: normally we would copy the rest of the source code later, but with dependencies
# between the modules it's currently not possible to do so.
# This should be optimized later to speed on build time!

# This is the actual application build.
# Rebuild the application
RUN touch ./apps/$APP/src/main.rs && \
    cargo build --release -p $APP --target $ARCH-unknown-linux-musl --bin $APP

################
##### Runtime
FROM alpine:3.18.3 AS runtime
ARG APP
ARG ARCH
ARG RUN_USER="app"
ARG RUN_GROUP="app"


# Copy application binary from builder image
COPY --from=builder /usr/src/$APP/target/$ARCH-unknown-linux-musl/release/$APP /usr/local/bin
RUN mv /usr/local/bin/$APP /usr/local/bin/app

# Create user as which to run the application
RUN addgroup "$RUN_GROUP" && adduser "$RUN_USER" -D -G "$RUN_GROUP" \
    && chown -R "$RUN_USER:$RUN_GROUP" /usr/local/bin/app
USER $RUN_USER

# Run the application
CMD ["/usr/local/bin/app"]
