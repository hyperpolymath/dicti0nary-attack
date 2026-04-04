# Containerfile for Podman
# dicti0nary-attack - Chapel-based password research tool
#
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2025 Security Research Team

FROM docker.io/chapel/chapel:latest

LABEL maintainer="Security Research Team"
LABEL description="dicti0nary-attack - Non-Dictionary Password Research Tool (Chapel/WASM)"
LABEL rsr.compliance="bronze"
LABEL rsr.score="86%"

# Install additional dependencies
RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    git \
    curl \
    emscripten \
    just \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Install Nickel (configuration language)
RUN curl -sSL https://github.com/tweag/nickel/releases/download/1.0.0/nickel-1.0.0-x86_64-linux.tar.gz \
    | tar xz -C /usr/local/bin

# Set working directory
WORKDIR /app

# Copy source files
COPY src/ ./src/
COPY web/ ./web/
COPY config/ ./config/
COPY justfile ./

# Copy Chapel module files
COPY Chapel.toml ./

# Compile Chapel to WASM
RUN just build-wasm

# Expose static file server port (if needed)
EXPOSE 8080

# Set environment variables
ENV CHPL_HOME=/opt/chapel
ENV PATH=$CHPL_HOME/bin:$PATH

# Default command
CMD ["just", "serve-static"]
