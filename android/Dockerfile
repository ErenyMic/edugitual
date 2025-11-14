# ============================================
# Stage 1: Builder - Install all dependencies
# ============================================
FROM ubuntu:22.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install OpenJDK 21 and tools
RUN apt-get update && \
    apt-get install -y \
        openjdk-21-jdk \
        wget \
        unzip \
        && rm -rf /var/lib/apt/lists/*

# Set up Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Install Android SDK Command-line Tools
ENV ANDROID_SDK_ROOT=/opt/android
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

RUN wget -q https://dl.google.com/android/repository/commandlinetools-linux-9123335_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip -q /tmp/cmdline-tools.zip -d /tmp && \
    mkdir -p $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    mv /tmp/cmdline-tools/* $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools

# Accept licenses & install SDK packages
RUN yes | sdkmanager --licenses > /dev/null 2>&1 && \
    sdkmanager --install \
        "platform-tools" \
        "platforms;android-34" \
        "build-tools;34.0.0" \
        > /dev/null


# ============================================
# Stage 2: Runtime - Minimal final image
# ============================================
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime essentials + sudo
RUN apt-get update && \
    apt-get install -y \
        openjdk-21-jdk \
        git \
        curl \
        sudo \
        && rm -rf /var/lib/apt/lists/*

# Create user and allow sudo without password (only for chown)
RUN groupadd -g 1000 dev && \
    useradd -m -u 1000 -g dev dev && \
    echo "dev ALL=(ALL) NOPASSWD: /bin/chown" >> /etc/sudoers

# Set up Java environment
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# Copy Android SDK from builder stage
ENV ANDROID_SDK_ROOT=/opt/android
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools
COPY --from=builder $ANDROID_SDK_ROOT $ANDROID_SDK_ROOT

# Set ownership
RUN chown -R dev:dev $ANDROID_SDK_ROOT

# Create app directories with correct ownership
RUN mkdir -p /app/output /app/src && \
    chown -R dev:dev /app

# Copy entrypoint script
COPY --chown=root:root ./android/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Copy build script
COPY --chown=dev:dev ./android/build-apk.sh /app/build-apk.sh
RUN chmod +x /app/build-apk.sh

WORKDIR /app

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s \
    CMD java -version || exit 1

# Set entrypoint to fix permissions, then switch to dev user
ENTRYPOINT ["/entrypoint.sh"]

# Note: No CMD set. Build script can be executed manually inside container:
# docker exec -it android /app/build-apk.sh