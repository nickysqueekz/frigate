# Stable base with broader apt repo support
FROM debian:bookworm

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /opt/frigate

# Install system packages and Python manually
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-dev python3-venv \
    ffmpeg \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1-mesa-glx \
    curl \
    ca-certificates \
    libopenjp2-7 \
    libtiff5 \
    libjpeg62-turbo \
    nano \
    htop \
    udev \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Coral support
RUN curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" > /etc/apt/sources.list.d/coral-edgetpu.list \
 && apt-get update && apt-get install -y --no-install-recommends libedgetpu1-max \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Coral USB rules
RUN curl -sSL https://coral.googlesource.com/edgetpu/+/refs/heads/release/edgetpu_api/99-edgetpu-accelerator.rules?format=TEXT \
 | base64 -d > /etc/udev/rules.d/99-edgetpu-accelerator.rules

# Copy Frigate source and install
COPY . .
RUN pip3 install --no-cache-dir .

EXPOSE 5000 8554 8555 1935 8880
CMD ["frigate"]
