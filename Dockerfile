FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    gcc \
    python3-dev \
    libffi-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

ENV HERMES_HOME=/root/.hermes
ENV HERMES_ALLOW_ROOT_GATEWAY=1
ENV PYTHONUNBUFFERED=1

ARG HERMES_VERSION

# 下载源码
RUN if [ -z "$HERMES_VERSION" ]; then \
        LATEST_URL=$(curl -s https://api.github.com/repos/NousResearch/hermes-agent/releases/latest | grep tarball_url | cut -d '"' -f 4); \
        curl -L --retry 3 "$LATEST_URL" -o /tmp/hermes.tar.gz; \
    else \
        curl -L --retry 3 "https://github.com/NousResearch/hermes-agent/archive/refs/tags/${HERMES_VERSION}.tar.gz" -o /tmp/hermes.tar.gz; \
    fi && \
    mkdir -p /opt/hermes && \
    tar -xzf /tmp/hermes.tar.gz -C /opt/hermes --strip-components=1 && \
    rm /tmp/hermes.tar.gz

WORKDIR /opt/hermes

# 安装依赖 + editable 安装
RUN pip install --upgrade pip setuptools wheel && \
    pip install -e .

EXPOSE 8642
CMD ["hermes", "gateway", "start", "--host", "0.0.0.0", "--port", "8642"]