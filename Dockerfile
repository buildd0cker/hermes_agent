FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

ENV HERMES_HOME=/root/.hermes
ENV HERMES_ALLOW_ROOT_GATEWAY=1

# 构建参数，默认值设为空，由 Actions 决定具体值
ARG HERMES_VERSION

# 如果 HERMES_VERSION 为空，则下载最新 Release 的源码包
RUN if [ -z "$HERMES_VERSION" ]; then \
        LATEST_URL=$(curl -s https://api.github.com/repos/NousResearch/hermes-agent/releases/latest | grep tarball_url | cut -d '"' -f 4); \
        curl -L $LATEST_URL -o /tmp/hermes.tar.gz; \
    else \
        curl -L https://github.com/NousResearch/hermes-agent/archive/refs/tags/${HERMES_VERSION}.tar.gz -o /tmp/hermes.tar.gz; \
    fi && \
    mkdir -p /opt/hermes && \
    tar -xzf /tmp/hermes.tar.gz -C /opt/hermes --strip-components=1 && \
    rm /tmp/hermes.tar.gz

WORKDIR /opt/hermes
RUN pip install --no-cache-dir .

EXPOSE 8642
CMD ["hermes", "gateway", "start", "--host", "0.0.0.0", "--port", "8642"]