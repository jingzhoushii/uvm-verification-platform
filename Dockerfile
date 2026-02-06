# ============================================================
# File: Dockerfile
# Description: UVM 验证平台 Docker 环境
# Author: UVM Verification Platform
# Created: 2026-02-06
# ============================================================

# 构建:
# docker build -t uvm-platform .
#
# 运行:
# docker run -it --rm -v $(pwd):/workspace uvm-platform
#
# 示例:
# docker run -it --rm -v $(pwd):/workspace uvm-platform make smoke

FROM ubuntu:20.04

# 维护者
MAINTAINER UVM Verification Platform

# 安装基础依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    gcc \
    g++ \
    make \
    git \
    python3 \
    python3-pip \
    vim \
    wget \
    curl \
    tcsh \
    csh \
    libncurses5-dev \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# 设置工作目录
WORKDIR /workspace

# 复制项目文件
COPY . /workspace/

# 环境变量
ENV PROJECT_DIR=/workspace
ENV PATH=/workspace/scripts:$PATH

# 默认命令
CMD ["/bin/bash"]

# 使用说明
LABEL description="UVM Verification Platform"
LABEL version="1.0.2"
LABEL maintainer="uvm-platform"
