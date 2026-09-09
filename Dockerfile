FROM python:3.11-slim

# 安装构建 Hermes 所需的系统依赖
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

# 构建参数：用于指定 GitHub Release 版本
ARG HERMES_VERSION=v2026.9.7

# 下载并解压指定版本的源码包
RUN curl -L https://github.com/NousResearch/hermes-agent/archive/refs/tags/${HERMES_VERSION}.tar.gz -o /tmp/hermes.tar.gz && \
    mkdir -p /opt/hermes && \
    tar -xzf /tmp/hermes.tar.gz -C /opt/hermes --strip-components=1 && \
    rm /tmp/hermes.tar.gz

WORKDIR /opt/hermes

# 升级 pip 并安装构建工具
RUN pip install --upgrade pip setuptools wheel

# 安装项目本身（pip 会自动处理 pyproject.toml 中的依赖）
RUN pip install --no-cache-dir .

EXPOSE 8642
CMD ["hermes", "gateway", "start", "--host", "0.0.0.0", "--port", "8642"]