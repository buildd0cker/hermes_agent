FROM python:3.11-slim

# 安装系统依赖
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

# 构建参数：版本号，由 Actions 传入
ARG HERMES_VERSION

# 下载源码：如果版本号为空，自动获取最新版
RUN if [ -z "$HERMES_VERSION" ]; then \
        echo "No version specified, fetching latest release..." && \
        LATEST_URL=$(curl -s https://api.github.com/repos/NousResearch/hermes-agent/releases/latest | grep tarball_url | cut -d '"' -f 4) && \
        echo "Latest URL: $LATEST_URL" && \
        curl -L --retry 3 --retry-delay 2 "$LATEST_URL" -o /tmp/hermes.tar.gz; \
    else \
        echo "Building Hermes version: $HERMES_VERSION" && \
        curl -L --retry 3 --retry-delay 2 "https://github.com/NousResearch/hermes-agent/archive/refs/tags/${HERMES_VERSION}.tar.gz" -o /tmp/hermes.tar.gz; \
    fi && \
    mkdir -p /opt/hermes && \
    tar -xzf /tmp/hermes.tar.gz -C /opt/hermes --strip-components=1 && \
    rm /tmp/hermes.tar.gz

WORKDIR /opt/hermes

# 升级 pip 并安装构建工具
RUN pip install --upgrade pip setuptools wheel

# 安装项目
RUN pip install --no-cache-dir .

EXPOSE 8642
CMD ["hermes", "gateway", "start", "--host", "0.0.0.0", "--port", "8642"]