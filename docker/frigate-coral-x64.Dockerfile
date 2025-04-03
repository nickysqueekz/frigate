# Frigate 0.16 optimized for Coral + CPU on x86_64
FROM python:3.11-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive

# ---- Install system and runtime packages ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libglib2.0-0 \
    libsm6 \
    libxrender1 \
    libxext6 \
    libgl1 \
    curl \
    ca-certificates \
    libatlas-base-dev \
    libopenjp2-7 \
    libtiff5 \
    libturbojpeg0 \
    nano \
    htop \
    udev \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- Install Coral EdgeTPU runtime (max performance) ----
RUN curl -sSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && echo "deb https://packages.cloud.google.com/apt coral-edgetpu-stable main" > /etc/apt/sources.list.d/coral-edgetpu.list \
 && apt-get update && apt-get install -y --no-install-recommends \
    libedgetpu1-max \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# ---- Add Coral USB udev rules ----
RUN curl -sSL https://coral.googlesource.com/edgetpu/+/refs/heads/release/edgetpu_api/99-edgetpu-accelerator.rules?format=TEXT \
 | base64 -d > /etc/udev/rules.d/99-edgetpu-accelerator.rules

# ---- Workdir and source copy ----
WORKDIR /opt/frigate
COPY . .

# ---- Install Frigate and dependencies ----
RUN pip install --no-cache-dir .

# ---- Expose Frigate ports ----
EXPOSE 5000 8554 8555 1935 8880

# ---- Healthcheck (optional) ----
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:5000 || exit 1

# ---- Run Frigate ----
CMD ["frigate"]
